require 'active_record'
#require "positionable"

require 'helper'
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
    ActiveRecord::Schema.define(:version => 1) do
        create_table :children do |t|
            t.column :pos, :integer
            t.column :parent_id, :integer
            t.column :parent_type, :string
            t.column :created_at, :datetime      
            t.column :updated_at, :datetime
        end
    end
end


def create_instances
    1.upto(10).each {|t| ChildList.create! :pos => t, :parent_id => 5 }
    11.upto(18).each  {|t| ChildList.create! :pos => t-10, :parent_id => 3 }
    19.upto(23).each  {|t| ChildList.create! :pos => t-8, :parent_id => 5 }
end

def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
    end
end

class Child < ActiveRecord::Base

end

class Parent
    @@instances = {}
    def self.create id
        return @@instances[id] unless @@instances[id].nil?
        @@instances[id] = Parent.new(id)
        @@instances[id]
    end

    def initialize _id
        @id = _id
    end

    def children
        ChildList.where(:parent_id => @id)
    end
end

class ChildList < Child
    positionable :position_column => :pos, :parent => :parent, :siblings => :children

    def self.table_name() "children" end
    def parent
        Parent.create(parent_id)
    end
end

class TestPositionable < Test::Unit::TestCase
    context "initials" do
        setup do
            setup_db
            create_instances

            @child = ChildList.create! :pos => 1, :parent_id => 1
        end

        teardown do
            teardown_db
        end

        should "work" do
            assert_equal ChildList.find(3).parent, ChildList.find(5).parent
            assert_not_equal ChildList.find(3).parent, ChildList.find(15).parent
            assert_equal Parent.create(5).children.size, 10+5
            assert_equal Parent.create(3).children.size, 8
            assert_equal @child.parent.children.size, 1
        end


    end
end

class TestPositionable1 < Test::Unit::TestCase
    context "positionable" do
        setup do
            setup_db
            create_instances

            @child = ChildList.find(2)
        end

        teardown do
            teardown_db
        end

        should "reposition on demand" do
            @child.reposition(5)
            assert_equal @child.pos, 5
        end
    end
end

class TestPositionable2 < Test::Unit::TestCase
    context "repositioned object" do
        setup do
            setup_db
            create_instances

            @child = ChildList.find(13)
            @parent = Parent.create 3

        end

        teardown do
            teardown_db
        end

        should " positions at start" do
            assert_equal [1, 2, 3, 4, 5, 6, 7, 8], @parent.children.collect {|c| c.pos}
            @child.reposition(14)
            assert_equal [1, 2, 14, 3, 4, 5, 6, 7], @parent.children.collect {|c| c.pos}

        end

        should " positions at start2" do
            @child = @parent.children.first
            assert_equal [1, 2, 3, 4, 5, 6, 7, 8], @parent.children.collect {|c| c.pos}
            @child.reposition(20)
            assert_equal [20, 1, 2, 3, 4, 5, 6, 7], @parent.children.collect {|c| c.pos}

        end
  
        should " positions at start3" do
            @child = @parent.children.last
            assert_equal [1, 2, 3, 4, 5, 6, 7, 8], @parent.children.collect {|c| c.pos}
            @child.reposition(20)
            assert_equal [1, 2, 3, 4, 5, 6, 7, 20], @parent.children.collect {|c| c.pos}

        end
    end
end
