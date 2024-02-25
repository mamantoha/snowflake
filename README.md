# Snowflake

[![Crystal CI](https://github.com/mamantoha/snowflake/actions/workflows/crystal.yml/badge.svg)](https://github.com/mamantoha/snowflake/actions/workflows/crystal.yml)

Snowflake ID generator implementation in Crystal programming language, which is designed to generate unique,
time-based identifiers using a 64-bit structure. These identifiers consist of a timestamp component,
a machine or process ID, and a sequence number to ensure uniqueness within the same millisecond.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     snowflake:
       github: mamantoha/snowflake
   ```

2. Run `shards install`

## Usage

```crystal
require "snowflake"

machine_id = 1_u64 # Assign a unique machine/process ID
generator = Snowflake.new(machine_id)
snowflake_id = generator.generate_id
puts snowflake_id

# To convert a Snowflake ID back to a UTC timestamp
utc_time = Snowflake.id_to_utc(snowflake_id)
puts utc_time
```

## Contributing

1. Fork it (<https://github.com/mamantoha/snowflake/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/your-github-user) - creator and maintainer
