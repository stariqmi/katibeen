module KatibeenHelper
end

# Module to generate unique url.
module UrlKeyGenerator

  # Generates a 5 character long random string
  def urlKeyGenerator
    # Used as a string from which characters are pulled out from random positions
    library = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    arr = []  # Empty array
    # Loop of length 5 to pick a random character from "library"
    # Push the character picked out into the empty array
    (1..5).each { arr << library[rand(61)] } 
    return arr.join # Join the array i.e make it a string and return it
  end

  # Checks each generated key for uniqueness and outputs only a unique key
  def uniqueUrlKeyGenerator
    url = urlKeyGenerator  # Generate a url
    # Extract the user in the user db with that url
    checkInUsers = User.find_by_url(url)
    
    # Loop while a user with the generated url exists already in the user db
    while checkInUsers != nil
      url = urlKeyGenerator # Generate a new url
      # Extract a user with the generated url in the user db
      checkInUsers = User.find_by_url(url)
    end

    # Extract the potential_user in the potential_user db with that url
    checkInPotentialUsers = PotentialUser.find_by_url(url)

    # Loop while a potential_user with the generated url exists already in the potential_user db
    while checkInPotentialUsers != nil
      url = urlKeyGenerator # Generate a new url
      # Extract a potential_user with the generated url in the potential_user db
      checkInPotentialUsers = PotentialUser.find_by_url(url)
    end

    return url # Return a unique url
  end
end
