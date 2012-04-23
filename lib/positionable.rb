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
            if !position_options[:parent].nil?
                parent = self.send(position_options[:parent])
                if !parent.nil? and parent.respond_to?(position_options[:siblings])
                    return parent.send(position_options[:siblings])
                end
            else
                if !position_options[:siblings].nil? and self.respond_to?(position_options[:siblings])
                    return self.send(position_options[:siblings])
                end
            end
            nil
       end

        # @param [Integer] new_position
        def reposition(new_position)
            return true if [position_options[:position_column], nil].include? new_position
            range = if new_position > positionable_position then positionable_position..new_position else new_position..positionable_position end

            siblings.where(position_options[:position_column] => range).update_all(positionable_move_siblings(positionable_position > new_position))

            self.send(position_options[:position_column].to_s + '=' , new_position)
            save
            self
        end

private
        # @param [boolean] direction
        def positionable_move_siblings(direction)
            s = position_options[:position_column].to_s + ' = ' + position_options[:position_column].to_s
            if direction
                s += ' + 1'
            else
                s += ' - 1'
            end
            s
        end

        def positionable_position
            return self.send(position_options[:position_column]) if self.respond_to?(position_options[:position_column])
            nil
        end

   end
end

ActiveRecord::Base.send :include, Positionable
