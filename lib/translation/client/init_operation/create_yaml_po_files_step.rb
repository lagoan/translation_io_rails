module Translation
  class Client
    class InitOperation < BaseOperation
      class CreateYamlPoFilesStep
        attr_reader :params

        def initialize(target_locales, yaml_file_paths)
          @target_locales  = target_locales
          @yaml_file_paths = yaml_file_paths
          @params          = {}
        end

        def run
          Translation.info "Importing translations from YAML files."
          all_flat_translations = {}

          @yaml_file_paths.each do |file_path|
            Translation.info file_path, 2
            all_flat_translations.merge!(YAMLConversion.get_flat_translations_for_yaml_file(file_path))
          end

          all_flat_string_translations = all_flat_translations.select do |key, value|
            value.is_a?(String)
          end

          source_flat_string_tanslations = all_flat_string_translations.select do |key|
            key.start_with?("#{Translation.config.source_locale}.")
          end

          @target_locales.each do |target_locale|
            po_representation = GetText::PO.new

            source_flat_string_tanslations.each_pair do |key, value|
              target_key = key.gsub(/\A#{Translation.config.source_locale}\./, "#{target_locale}.")
              msgid      = value
              msgstr     = all_flat_string_translations[target_key]

              unless msgid.blank?
                po_entry            = GetText::POEntry.new(:msgctxt)
                po_entry.msgid      = msgid
                po_entry.msgstr     = msgstr
                po_entry.msgctxt    = key.split('.', 2).last
                #po_entry.references = [ value[:locale_file_path] ]

                po_representation[po_entry.msgctxt, po_entry.msgid] = po_entry
              end
            end

            @params["yaml_po_data_#{target_locale}"] = po_representation.to_s
          end
        end
      end
    end
  end
end