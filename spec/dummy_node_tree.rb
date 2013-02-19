class ExampleNode < KtouthBrand::ST2::Node
  class <<self
    public :new
  end
  def initialize(_id)
    super()
    @id = _id
  end
  attr_reader :id
  def inspect; "<Example: #{id}>" end
  def each_error_message; end
end
def create_nodes(num); num.to_i.times.map {|x| ExampleNode.new(x) } end
def assign_each_node(owner, array, *indexes)
  klass = class <<owner; self end
  klass.send(:define_method, :each_node) do |&block|
    indexes.each {|x| block.call(array[x]) }
  end
end

shared_context 'tree nodes' do
  #  1 -   4 -  11
  #             12 -  22
  #        5
  #        6 -  13
  #  2 -   7 -  14
  #             15 -  23 -  31
  #                         32 -  33 -  34
  #                                     35
  #                   24
  #                   25
  #             16
  #             17
  #             18 -  26
  #                   27
  #             19
  #        8 -  20 -  28
  #                   29
  #                   30
  #        9
  #  3 -  10 -  21
  before do
    @nodes = create_nodes(36)
    assign_each_node(@nodes[33], @nodes, 34, 35)
    assign_each_node(@nodes[32], @nodes, 33)
    assign_each_node(@nodes[23], @nodes, 31, 32)
    assign_each_node(@nodes[20], @nodes, 28, 29, 30)
    assign_each_node(@nodes[18], @nodes, 26, 27)
    assign_each_node(@nodes[15], @nodes, 23, 24, 25)
    assign_each_node(@nodes[12], @nodes, 22)
    assign_each_node(@nodes[10], @nodes, 21)
    assign_each_node(@nodes[ 8], @nodes, 20)
    assign_each_node(@nodes[ 7], @nodes, 14, 15, 16, 17, 18, 19)
    assign_each_node(@nodes[ 6], @nodes, 13)
    assign_each_node(@nodes[ 4], @nodes, 11, 12)
    assign_each_node(@nodes[ 3], @nodes, 10)
    assign_each_node(@nodes[ 2], @nodes, 7, 8, 9)
    assign_each_node(@nodes[ 1], @nodes, 4, 5, 6)
    assign_each_node(@nodes[ 0], @nodes, 1, 2, 3)
    @tree_current_indexes = [0, 1, 4, 11, 12, 22, 5, 6, 13, 2, 7, 14, 15, 23, 31, 32, 33, 34, 35, 24, 25, 16, 17, 18, 26, 27, 19, 8, 20, 28, 29, 30, 9, 3, 10, 21]
    @tree_before_indexes  = [nil, nil, nil, nil, 11, nil, 4, 5, nil, 1, nil, nil, 14, nil, nil, 31, nil, nil, 34, 23, 24, 15, 16,17, nil, 26, 18, 7, nil, nil, 28, 29, 8, 2, nil, nil]
    @tree_after_indexes   = [nil, 2, 5, 12, nil, nil, 6, nil, nil, 3, 8, 15, 16, 24, 32, nil, nil, 35, nil, 25, nil, 17, 18, 19, 27, nil, nil, 9, nil, 29, 30, nil, nil, nil, nil, nil]
    @tree_parent_indexes  = [nil, 0, 1, 4, 4, 12, 1, 1, 6, 0, 2, 7, 7, 15, 23, 23, 32, 33, 33, 15, 15, 7, 7, 7, 18, 18, 7, 2, 8, 20, 20, 20, 2, 0, 3, 10]
  end
end

def assign_each_error_message(node, &block)
  klass = class <<node; self end
  klass.send(:define_method, :each_error_message, &block)
end

def assign_format_for(node, sym, &block)
  klass = class <<node; self end
  sym = "format_for_#{sym}".to_sym
  klass.send(:define_method, sym, &block)
  klass.send(:private, sym)
end

#def assign_call_node(formatter, *types)
#  klass = class <<formatter; self end
#  klass.module_eval <<-ENDE
#    def call_node(c); super(c#{types.map {|x| ', %s' % x.inspect }.join}) end
#  ENDE
#  klass.send(:private, :call_node)
#end

