module Types
  include Dry::Types()

  Color = String.constrained(format: /#[a-f0-9]{3}|#[a-f0-9]/i)
end