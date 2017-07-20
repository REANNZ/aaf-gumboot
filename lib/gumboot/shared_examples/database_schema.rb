# frozen_string_literal: true

RSpec.shared_examples 'Database Schema' do
  context 'AAF shared implementation' do
    RSpec::Matchers.define :have_collation do |expected, name|
      match { |actual| actual[:Collation] == expected }

      failure_message do |actual|
        "expected #{name} to use collation #{expected}, but was " \
          "#{actual[:Collation]}"
      end
    end

    before { expect(connection).to be_a(Mysql2::Client) }

    def query(sql)
      connection.query(sql, as: :hash, symbolize_keys: true)
    end

    it 'has the correct encoding set for the connection' do
      expect(connection.query_options).to include(encoding: 'utf8')
    end

    it 'has the correct collation set for the connection' do
      expect(connection.query_options).to include(collation: 'utf8_bin')
    end

    it 'has the correct collation' do
      exemptions = defined?(collation_exemptions) ? collation_exemptions : []

      db_collation = query('SHOW VARIABLES LIKE "collation_database"')
                     .first[:Value]
      expect(db_collation).to eq('utf8_bin')

      query('SHOW TABLE STATUS').each do |table|
        table_name = table[:Name]
        next if table_name == 'schema_migrations'
        expect(table).to have_collation('utf8_bin', "`#{table_name}`")

        query("SHOW FULL COLUMNS FROM #{table_name}").each do |column|
          next unless column[:Collation]
          next if exemptions.any? do |(except_table, except_column)|
                    except_table == table_name.to_sym &&
                    except_column == column[:Field].to_sym
                  end
          expect(column)
            .to have_collation('utf8_bin',
                               " `#{table_name}`.`#{column[:Field]}`")
        end
      end
    end
  end
end
