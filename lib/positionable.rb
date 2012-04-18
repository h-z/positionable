module Positionable
  def self.included(base)
      base.extend(ClassMethods)
  end

  module ClassMethods
      # @param [Hash] options
      def positionable(options = {})
        configuration = { :parent => nil, :siblings => nil }
        configuration.update(options) if options.is_a?(Hash)

        define_method :position_options do
          configuration
        end

        include InstanceMethods
      end
  end

  module InstanceMethods
    def siblings
      if position_options[:parent].nil? and position_options[:siblings].nil?
        return nil
      end
      self.send(position_options[:parent]).send(position_options[:siblings])
    end

    # @param [Integer] new_position
    def reposition(new_position)
      return true if [position, nil].include? new_position
      range = if new_position > position then position..new_position else new_position..position end
      siblings.where(:position => range).each do |movable|
        if position > new_position
          movable.position = movable.position + 1
        else
          movable.position = movable.position - 1
        end
        movable.save
      end
      self.position= new_position
      save
    end

  end
e
