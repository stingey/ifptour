class TeamFormatterError < StandardError
  attr_reader :errors

  def initialize(msg: 'A team formatting error has occurred')
    super(msg)
  end
end
