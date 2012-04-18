module Positionable
  def self.included(base)
      base.extend(ClassMethods)
  end

  module ClassMethods
      # @param [Hash] options
      def positionable(options = {})
        configuration = { :parent => nil, :siblings => nil, :position_column => :position }
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
    
    def positionable_position
        return self.send(position_options[:position_column]) if self.respond_to?(position_options[:position_column])
        nil
    end

    # @param [Integer] new_position
    def reposition(new_position)
      return true if [position_options[:position_column], nil].include? new_position
      range = if new_position > positionable_position then positionable_position..new_position else new_position..positionable_position end
      siblings.where(:position => range).each do |movable|
        if positionable_position > new_position
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
end

ActiveRecord::Base.send :include, Positionable
