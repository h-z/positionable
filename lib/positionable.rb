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

        # @param [Integer] new_position
        def reposition(new_position)
            return true if [position_options[:position_column], nil].include? new_position
            range = if new_position > positionable_position then positionable_position..new_position else new_position..positionable_position end

            siblings.where(:position => range).update_all(positionable_move_siblings(positionable_position > new_position))
"""
            siblings.where(:position => range).each do |movable|
                begin
                    if positionable_position > new_position
                        movable.position = movable.send(position_options[:position_column]) + 1
                    else
                        movable.position = movable.send(position_options[:position_column]) - 1
                    end
                rescue
                end
                movable.save
            end
            """
            self.position= new_position
            save
        end

private
        def positionable_move_siblings direction
            s = position_options[:position_column].to_s + ' = ' + position_options[:position_column] 
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
