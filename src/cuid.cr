##
# Cuid is a library for generating unique collision-resistant IDs optimized for horizontal scaling and performance
#
# @example Generate a hash
#   hash = Cuid::generate #=> "ch8qypsnz0000a4welw8anyr"
#
# @example Generate 2 hashes
#   hashes = Cuid::generate(2) #=> ["ch8qyq35f0002a4wekjcwmh30", "ch8qyq35f0003a4weewy22izq"]
#
# @see http://github.com/dilvie/cuid Original author's detailed explanation of the cuid spec

module Cuid
  @@fingerprint : String = ""

  ##
  # @private
  @@count = 0_u32

  ##
  # length of each segment of the hash
  BLOCK_SIZE = 4_u64

  ##
  # size of the alphabet (e.g. base36 is [a-z0-9])
  BASE = 36_u64

  ##
  # @private
  # maximum number that can be stored in a block of the specified size using the specified alphabet
  DISCRETE_VALUES = (BASE ** BLOCK_SIZE) - 1

  ##
  # size of the random segment of the block
  RAND_SIZE = BLOCK_SIZE * 2

  ##
  # @private
  # maximum number that can be stored in the random block
  RAND_MAX = (BASE ** RAND_SIZE) - 1

  ##
  # @private
  # minimum number that can be stored in the random block (otherwise it will be too short)
  RAND_MIN = BASE ** (RAND_SIZE - 1)

  ##
  # @private
  # first letter of the hash
  LETTER = "c"

  module ClassMethods
    ##
    # Returns one or more hashes based on the parameter supplied
    #
    # @overload generate()
    #   Returns one hash when called with no parameters or a parameter of 1
    #
    #   @param [optional, Integer] quantity determines number of hashes returned (must be nil, 0 or 1)
    #   @return [String]
    #
    # @overload generate(quantity)
    #   Returns an array of hashes when called with a parameter greater than 1
    #
    #   @param [Integer] quantity determines number of hashes returned (must be greater than 1)
    #   @return [Array<String>]
    #
    # @overload generate(quantity,secure_random)
    #   Returns an array of hashes when called with a parameter greater than 1
    #
    #   @param [Integer] quantity determines number of hashes returned (must be greater than 1)
    #   @param [Boolean] secure_random attempts to use SecureRandom if set to True (Ruby 1.9.2 and up; reverts to Kernel#rand if SecureRandom is not supported)
    #   @return [Array<String>]
    def generate(quantity = 1) : String
      @@fingerprint = get_fingerprint # only need to get the fingerprint once because it is constant per-run
      # return api unless quantity > 1

      # values = Array(String).new(quantity) # create an array of the correct size
      # return values.map { api }            # fill array with hashes
      api
    end

    def generate_many(quantity = 1)
      @@fingerprint = get_fingerprint # only need to get the fingerprint once because it is constant per-run
      # return api unless quantity > 1

      values = Array(String).new # (quantity, '0') # create an array of the correct size
      quantity.times do
        values << api
      end
      return values
    end

    ##
    # Validates (minimally) the supplied string is in the correct format to be a hash
    #
    # Validation checks that the first letter is correct and that the rest of the
    # string is the correct length and consists of lower case letters and numbers.
    #
    # @param [String] str string to check
    # @return [Boolean] returns true if the format is correct
    def validate(str)
      blen = BLOCK_SIZE * 6
      !!str.match(/#{LETTER}[a-z0-9]{#{blen}}/)
    end

    ##
    # Collects and asssembles the pieces into the actual hash string.
    #
    # @private
    private def api
      timestamp = (Time.utc.to_unix_f * 1000).to_u64.to_s(BASE)

      random = get_random_block

      @@count = @@count % DISCRETE_VALUES
      counter = pad(@@count.to_s(BASE))

      @@count += 1

      # puts "Letter:        #{LETTER}"
      # puts "timestamp:     #{timestamp}"
      # puts "counter:       #{counter}"
      # puts "@@fingerprint: #{@@fingerprint}"
      # puts "random:        #{random}"

      return (LETTER + timestamp + counter + @@fingerprint + random)
    end

    ##
    # Returns a string which has been converted to the correct size alphabet as defined in
    # the BASE constant (e.g. base36) and then padded or trimmed to the correct length.
    #
    # @private
    private def format(text : Int32, size = BLOCK_SIZE)
      base36_text = text.to_s(BASE)
      return (base36_text.size > size) ? trim(base36_text, size) : pad(base36_text, size)
    end

    ##
    # Returns a string trimmed to the length supplied or BLOCK_SIZE if no length is supplied.
    #
    # @private
    private def trim(text, max = BLOCK_SIZE)
      original_length = text.size
      return text[original_length - max, max]
    end

    ##
    # Returns a string right-justified and padded with zeroes up to the length supplied or
    # BLOCK_SIZE if no length is supplied.
    #
    # @private
    private def pad(text, size = BLOCK_SIZE)
      return text.rjust(size, '0')
    end

    ##
    # Generates a random string.
    #
    # @private
    private def get_random_block
      # ruby
      # 2821109907455
      #   78364164096
      # crystal
      # 18446744073025945599
      # 1054752768
      # puts "random max: #{RAND_MAX}"
      # puts "random min: #{RAND_MIN}"
      number = Random::Secure.rand(RAND_MAX - RAND_MIN) + RAND_MIN

      return number.to_s(BASE)
    end

    ##
    # Assembles the host fingerprint based on the hostname and the PID.
    #
    # @private
    private def get_fingerprint
      padding = 2
      hostname = System.hostname
      a = 0
      hostname.each_char do |char|
        a += (char.responds_to?(:ord)) ? char.ord : char[0]
      end
      return format(Process.pid, padding) + format(a, padding)
    end
  end

  extend ClassMethods
end
