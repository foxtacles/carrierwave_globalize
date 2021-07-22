# frozen_string_literal: true

require 'carrierwave'

# Manage CarrierWave and Globalize to work together
module CarrierwaveGlobalize
  def mount_translated_uploader(column, uploader = nil, options = {}, &block)
    mount_uploader(column, uploader, options, &block)
    delegate :"#{column}_will_change!", :"#{column}_changed?",
             to: :translation

    self::Translation.send(:mount_uploader, column, uploader, options, &block)
    return if carrierwave_globalize_initialized?

    include CarrierwaveGlobalize::InstanceMethods
    @carrierwave_globalize_initialized = true
  end

  def carrierwave_globalize_initialized?
    @carrierwave_globalize_initialized || false
  end

  # Instance methods necessary to make
  module InstanceMethods
    def self.included(model)
      model.instance_eval do
        private :_mounter, :_translations_mounter
      end
    end

    def _mounter(column)
      if translated_attribute_names.include?(column)
        _translations_mounter(column)
      else
        super(column)
      end
    end

    def _translations_mounter(column)
      @_translations_mounter ||= {}
      (@_translations_mounter[Globalize.locale.to_sym] ||= {})[column] ||= \
        if defined?(CarrierWave::Mounter)
          # CarrierWave >= 1.0.0
          ::CarrierWave::Mounter.new(self, column)
        else
          # CarrierWave < 1.0.0
          ::CarrierWave::Mount::Mounter.new(self, column)
        end
    end
  end
end

require 'carrierwave_globalize/version'
