class ChallongeApiError < StandardError
  attr_reader :errors

  def initialize(errors: nil, msg: 'A Challonge api error has occurred')
    @errors = errors
    super(msg)
  end
end
