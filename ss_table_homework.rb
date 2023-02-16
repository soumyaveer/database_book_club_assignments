# Implement an SSTable (Sorted String Table)!
#
# This is intentional small.  We will use your implementation to build an LSMTree after.
#
# @see https://www.igvita.com/2012/02/06/sstable-and-log-structured-storage-leveldb/
class SSTable
  Error = Class.new(StandardError)
  Full = Class.new(Error)
  Missing = Class.new(Error)

  attr_reader :byte_size
  attr_accessor :table

  def initialize(byte_size)
    @byte_size = byte_size
    @table = {}
    @current_byte_size = 0
  end

  # This should be done in constant time: O(1)
  def fetch(key_s)
    raise SSTable::Missing if table[key_s].nil?

    table[key_s]
  end

  # This should be done in constant time: O(1)
  #
  # Make sure to respect your byte_size limit!
  # Ruby will just keep giving you more memory if you continue to ask for it
  #
  # @see String#bytesize
  def insert(key_s, value_s)
    @current_byte_size += value_s.bytesize

    raise SSTable::Full if byte_size_exceeded?

    table[key_s] = value_s
  end

  private
  def byte_size_exceeded?
    @current_byte_size >= byte_size
  end
end


require 'test/unit'
include Test::Unit::Assertions

ss_table = SSTable.new(2**12) # 4k

# load
(100..999).each do |key|
  # simplifying to make the key and value be the same thing
  ss_table.insert(key.to_s, key.to_s)
end

# fetch
(100..999).each do |key|
  assert_equal ss_table.fetch(key.to_s), key.to_s
end

assert_raise(SSTable::Missing) { ss_table.fetch("1000") }

smol_table = SSTable.new(2**11) # 2k, not big enough for 900 * 3 = 2700 bytes

assert_raise(SSTable::Full) do
  (100..999).each do |key|
    smol_table.insert(key.to_s, key.to_s)
  end
end