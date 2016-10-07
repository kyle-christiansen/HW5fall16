# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "(.*?)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  movies_table.hashes.each do |movie|
   if !Movie.find_by(:title => movie[:title], :rating=> movie[:rating], :release_date => movie[:release_date])
        Movie.create!(:title => movie[:title], :rating=> movie[:rating], :release_date => movie[:release_date])
    end
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  rating_list = arg1.split(', ')
  all_ratings = Movie.all_ratings
  all_ratings.each do |rating|
    if rating_list.index(rating)
        check("ratings[#{rating}]")
    else
        uncheck("ratings[#{rating}]")
    end
  end
  click_button('Refresh')
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
    moviesWithRating = 0
    ratings = arg1.split(', ')
    
    #Check to make sure the number of results match
    ratings.each do |rating|
        moviesWithRating += Movie.where(rating: "#{rating}").size
    end
    realMovieAmount = (moviesWithRating == all("tr").size - 1)
    
    #make sure all the movie have the correct ratings
    invalidMovies=false
    all("tr").each do |row|
        foundRating = false
        ratings.each do |currRating|
            if row.has_content?(currRating)
                foundRating = true
                break
            end
        end
        if !foundRating
           invalidMovies = true
           break
        end
    end  
  expect(!invalidMovies && realMovieAmount).to be_truthy
end

Then /^I should see all of the movies$/ do
  #check to make sure there is the same number of movies in the table
  numbersMatch = all('tr').size == Movie.all.size+1
  
  #check to make sure the movie names are the same
  moviesMatch = true
  Movie.all.each do |movie|
      foundMovie = false
      all('tr').each do |row|
          if row.has_content?(movie.title) && row.has_content?(movie.rating) && row.has_content?(movie.release_date)
            foundMovie = true 
            break
          end
      end
      if !foundMovie
          moviesMatch = false
      end
  end
  expect(moviesMatch && numbersMatch).to be_truthy
end


When /^I have opted to see movies in alphabetical order$/ do
    click_link("title_header")
end

When /^I have opted to see movies in order of release date$/ do
    click_link("release_date_header")
end

#make sure the movies are in order
Then /^I should see the title "(.*?)" before "(.*?)"$/ do |arg1, arg2|
    pageBody = page.body
    movie1 = pageBody.index(arg1)
    movie2 = pageBody.index(arg2)
    
    expect(defined?(movie1) && defined?(movie2) && movie1 < movie2).to be_truthy
end

#make sure all the movies are there
Then /^I should see all the movies$/ do
    allMovies = all('tr').size == Movie.all.size+1
    expect(allMovies).to be_truthy
end