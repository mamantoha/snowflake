require "./spec_helper"

describe Snowflake do
  describe "#generate_id" do
    generator = Snowflake.new(1_u64)

    it "generates unique IDs across multiple calls" do
      id1 = generator.generate_id
      id2 = generator.generate_id
      id3 = generator.generate_id
      (id1 != id2 && id1 != id3 && id2 != id3).should be_true
    end

    it "raises an error for invalid machine IDs" do
      expect_raises(ArgumentError, "Machine ID must be between 0 and #{Snowflake::MAX_MACHINE_ID}") do
        Snowflake.new(Snowflake::MAX_MACHINE_ID.to_u64 + 1_u64)
      end
    end
  end

  describe ".id_to_utc" do
    generator = Snowflake.new(1_u64)

    it "converts a snowflake ID back to the correct UTC timestamp" do
      # https://twitter.com/Wikipedia/status/1541815603606036480
      snowflake_id = 1541815603606036480_u64

      generated_time = Snowflake.id_to_utc(snowflake_id)

      expected_time = Time.utc(2022, 6, 28, 16, 7, 40, nanosecond: 105000000)

      converted_time = Snowflake.id_to_utc(snowflake_id)

      converted_time.should eq(expected_time)
    end
  end
end
