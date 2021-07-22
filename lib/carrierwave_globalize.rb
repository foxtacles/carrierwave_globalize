# frozen_string_literal: true

require 'carrierwave'

# Manage CarrierWave and Globalize to work together
module CarrierwaveGlobalize
  def mount_translated_uploader(column, uploader = nil, options = {}, &block)
    mount_uploader(column, uploader, options, &block)
    self::Translation.send(:mount_uploader, column, uploader, options, &block)

    delegate :"#{column}_will_change!", :"#{column}_changed?",
             to: :translation

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
        private :_mounter
      end
    end

    def _mounter(column)
      if translated_attribute_names.include?(column)
        translation.send("_mounter", column)
      else
        super(column)
      end
    end
  end
end

require 'carrierwave_globalize/version'
