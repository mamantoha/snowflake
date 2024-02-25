# The Snowflake class implements a Snowflake ID generator, which is designed to generate unique,
# time-based identifiers using a 64-bit structure. These identifiers consist of a timestamp component,
# a machine or process ID, and a sequence number to ensure uniqueness within the same millisecond.
#
# The 64-bit ID is composed as follows:
# - 1 bit is unused (always set to 0).
# - 41 bits are used to store the milliseconds since a custom epoch, allowing for 69 years of unique timestamps.
# - 10 bits are allocated for the machine ID, allowing up to 1024 machines or processes.
# - 12 bits are used for the sequence number, allowing up to 4096 IDs to be generated per millisecond, per machine.
#
# This implementation uses the Twitter epoch of 1288834974657 milliseconds since the Unix epoch (1970-01-01 00:00:00 UTC),
# which corresponds to November 4, 2010, 01:42:54.657 UTC. This epoch is the reference point from which all timestamps
# in Snowflake IDs are calculated.
#
# Usage:
#
# ```
# machine_id = 1_u64 # Assign a unique machine/process ID
# generator = Snowflake.new(machine_id)
# snowflake_id = generator.generate_id
# puts snowflake_id
#
# # To convert a Snowflake ID back to a UTC timestamp
# utc_time = Snowflake.id_to_utc(snowflake_id)
# puts utc_time
# ```
#
# NOTE: The machine ID must be unique across all instances of the generator to ensure the uniqueness of generated IDs.
#
# Used resources:
#
# - https://developer.twitter.com/en/docs/twitter-ids
# - https://en.wikipedia.org/wiki/Snowflake_ID
# - https://keeplearning.dev/twitter-snowflake-approach-is-cool-3156f78017cb
class Snowflake
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  EPOCH   = 1288834974657

  # Constants for bit lengths
  TIMESTAMP_BITS  = 41
  MACHINE_ID_BITS = 10
  SEQUENCE_BITS   = 12

  # Maximum values
  MAX_MACHINE_ID = (1 << MACHINE_ID_BITS) - 1
  MAX_SEQUENCE   = (1 << SEQUENCE_BITS) - 1

  # Bit shifts
  TIMESTAMP_SHIFT  = MACHINE_ID_BITS + SEQUENCE_BITS
  MACHINE_ID_SHIFT = SEQUENCE_BITS

  @machine_id : UInt64
  @sequence : UInt64 = 0
  @last_timestamp : Int64 = -1

  def initialize(@machine_id : UInt64)
    raise ArgumentError.new("Machine ID must be between 0 and #{MAX_MACHINE_ID}") unless @machine_id <= MAX_MACHINE_ID
  end

  # Generates a unique Snowflake ID based on the current time, machine ID, and an internal sequence.
  def generate_id : UInt64
    current_timestamp = current_time

    if current_timestamp == @last_timestamp
      @sequence = (@sequence + 1) & MAX_SEQUENCE

      current_timestamp = wait_for_next_millisecond(current_timestamp) if @sequence == 0
    else
      @sequence = 0
    end

    @last_timestamp = current_timestamp

    # Explicitly cast the final result to UInt64
    (((current_timestamp - EPOCH).to_u64) << TIMESTAMP_SHIFT) |
      (@machine_id.to_u64 << MACHINE_ID_SHIFT) |
      @sequence.to_u64
  end

  private def current_time : Int64
    Time.utc.to_unix_ms
  end

  private def wait_for_next_millisecond(timestamp : Int64) : Int64
    while current_time == timestamp
      # Busy-wait
    end

    current_time
  end

  # Converts a given `snowflake_id` back to the UTC timestamp representing
  def self.id_to_utc(snowflake_id : UInt64) : Time
    # Extract timestamp part by shifting right (discard machine ID and sequence number bits)
    timestamp = ((snowflake_id >> 22) + EPOCH).to_i64

    Time.unix_ms(timestamp)
  end
end
