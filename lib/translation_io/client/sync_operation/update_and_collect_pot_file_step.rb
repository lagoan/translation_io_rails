module TranslationIO
  class Client
    class SyncOperation < BaseOperation
      class UpdateAndCollectPotFileStep
        def initialize(pot_path, source_files)
          @pot_path     = pot_path
          @source_files = source_files + Dir['tmp/translation/*.rb']
        end

        def run(params)
          TranslationIO.info "Updating POT file."
          GetText::Tools::XGetText.run(*@source_files, '-o', @pot_path,
                                       '--msgid-bugs-address', TranslationIO.config.pot_msgid_bugs_address,
                                       '--package-name',       TranslationIO.config.pot_package_name,
                                       '--package-version',    TranslationIO.config.pot_package_version,
                                       '--copyright-holder',   TranslationIO.config.pot_copyright_holder,
                                       '--copyright-year',     TranslationIO.config.pot_copyright_year.to_s)

          params['pot_data'] = File.read(@pot_path)
          puts params['pot_data']
        end
      end
    end
  end
end
