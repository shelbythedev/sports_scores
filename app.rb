require 'pathname'
require 'active_support/inflector'

# A FEW NOTES:
# I have refactored this to a (probably somewhat) extreme abstraction level.
# I did this to demonstrate skills in areas of abstraction, as well as local vs instance
# variables and a few other skills around the nuances of Ruby. My method was to first do the "quick-and-dirty" method, then refactor as
# patterns emerged. 
#
# Also, due to the iterative approach, I chose not to write tests up front
# in true TDD fashion. I wanted to keep this brief, as well as the simplicity of this
# program somewhat limits the testability. I am more than happy to talk through how I would
# test this if it were part of a larger service.

def run_app
    games = []
    @standings = []

    # load file from cli arg and parse teams and games
    # NOTE: for this exercise, if CLI argument is omitted, 
    # it will load the sample file by default
    load_file.each do |line|
        game = []

        # get game's teams, fetch scores, and ensure team is listed in standings
        teams = line.chomp.split(", ")

        teams.each do |team|
            team_stats = parse_game(team)
            add_team_to_standings(team_stats[:name])

            game << team_stats
        end

        games << game
    end

    # determine if tie game
    games.each do |game|
        if game.first[:score] == game.last[:score]
            its_a_tie(game)
        else
            determine_winner(game)
        end
    end

    # return and print winners by placement
    output_placements
end

private

def load_file
    # use first cli arg as path, discard all other inputs
    file_path, *misc = ARGV

    # for our purposes, and for testing, 
    # we'll load the sample file if arg is excluded
    file_path ||= "./sample-input.txt"

    File.open(file_path)    
end

# parse out a teams name and score from game
def parse_game team
    parsed_team = team.rpartition(' ')

    name = parsed_team.first
    score = parsed_team.last.to_i

    {
        name: name,
        score: score
    }
end

# check if team is already in standings;
# if not, add
def add_team_to_standings team_name
    if !@standings.any? {|team| team[:name] == team_name}
        @standings << {
                name: team_name,
                winnings: 0
            }
    end
end

# fetch team from standings array
def get_team_by_name team
    @standings.detect {|t| t[:name] == team[:name]}
end

# handle tie with both teams getting 1 point
def its_a_tie game
    game.each do |team|
        team_standings = get_team_by_name(team)
        team_standings[:winnings] += 1
    end
end

# normal game, winner gets 3 pts
def determine_winner game
    winner = game.max_by {|team| team[:score]}
    team_standings = get_team_by_name(winner)
    team_standings[:winnings] += 3
end

# determine placements and print to console
def output_placements
    @standings.sort_by! {|team| team[:winnings]}.reverse!

    @standings.each_with_index do |team, index|
        # if not first iteration, and this ties last loop, keep place same
        if @prev_winnings && team[:winnings] == @prev_winnings
            place = @prev_place
        # otherwise, reference index for placement
        else
            place = index + 1
        end

        pts = "pt"
        @prev_winnings = team[:winnings]  # store both of these for reference on next loop
        @prev_place = place

        # return output to console
        puts "#{place}. #{team[:name]}, #{team[:winnings]} #{pts.pluralize(team[:winnings])}"
    end
end

run_app