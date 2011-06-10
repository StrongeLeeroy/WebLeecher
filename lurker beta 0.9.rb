require 'rubygems'
require 'mechanize'
require 'digest/md5'
require 'rbconfig' #Library to detect the OS

class Menu
	def Menu.forumchoice
		puts "Time to select the forum"
		puts "Applications: 51"
		puts "Games: 43"
		puts "Music: 55" 
		puts "Anime: 42"
		puts "Movies: 56"
		puts "Number:"
		forum=gets.chomp
		return forum
	end	
end

def arraymen(width,height)
a = Array.new(width)
a.map! { Array.new(height) }
return a
end



puts "#############################"
puts "########## I am #############"
puts "####### Motherfucker ########"
puts "#############################"

puts "\n"
puts "Welcome to the fucking ultimate leecher"
puts "For now, its only compatible with tehparadox.com"
puts ""

=begin code to ask for a username / password
puts "Enter your username"
username=gets.chomp
puts "Enter Password"
password=gets.chomp
=end

username="strongeman"
password="tetillas"

### calculate md5 hash ###
digest = Digest::MD5.hexdigest(password)
agent = Mechanize.new 
### Load index page ###
page = agent.get("http://tehparadox.com/forum/index.php")
### Shows page title ###
puts agent.page.title()
### Load login form ###
login_form = agent.page.form_with(:action => 'http://tehparadox.com/forum/login.php?do=login')
### Populate the login form ###
login_form['vb_login_username'] = username
login_form['vb_login_password'] = password
login_form['vb_login_md5password_utf'] = digest
login_form['vb_login_md5password'] = digest
login_form['s'] = ""
login_form['securitytoken'] = "guest"
login_form['do'] = "login"
login_form['cookieuser'] = "1"

### Submit the login form ###
page = agent.submit login_form

### Look for the security token ###
page=agent.get("http://tehparadox.com/forum/search.php")
@token=""
### Load the whole page ###
troll = page.parser.xpath('/html').map do |row|
  test=row.text.to_s
  if test=~ /SECURITY/
      File.open('temp.txt','w') do |f|
        f.puts test
      end
      File.open('temp.txt', 'r') do |f|
        while line = f.gets
          if line =~ /SECURITY/
			@token=line
          end
        end
      end
  end
  
### Trim the string to just the actual token ###
	@token=@token.scan(/\"([^.]+)\"/).to_s
### This makes the code windows compatible###
	if Config::CONFIG['host_os'] =~ /mswin|mingw/
		@OS=1
		tama=@token.length - 6
		puts @token
		@token=@token[3,tama]
		puts "token:"+@token
		puts "windows detected"
	else
		puts "Windows not detected"
	end
### Windows code ends ###	
end

securitytoken=@token

### Load the search form ###
search_form = agent.page.form_with(:action => 'search.php?do=process')
### Populate the search form ###
childforums2 = 1
prefixchoice2 = "MU"
#system('cls')
### Get query ###
puts "hay mane, what ya wane look for?"
query2=gets
### Get the forum choice ###
forumchoice2=Menu.forumchoice

### Complete search form with data and token ###
search_form['query'] = query2
search_form['titleonly'] = 1
search_form['forumchoice[]'] = forumchoice2
search_form['childforums'] = childforums2
search_form['prefixchoice[]'] = prefixchoice2
search_form['s'] = ""
search_form['securitytoken'] = securitytoken
search_form['do'] = "process"
search_form['searchthreadid'] = ""
### submit the search form ###
page=agent.submit search_form
### parse all the threads into a temporary txt ###
threadmen = page.parser.xpath('//*[@id="threadslist"]').map do |row|
	puts "parsing threads"
	if row.text =~ /[MU]/
		File.open('temp.txt', 'w') do |f|
			f.puts row
		end
	end
end

### Make sure that "threads.txt" exists ###
File.open("threads.txt",'w') do |nothing|
end
### Get the thread titles from the file ###
File.open('temp.txt', 'r') do |f2|
  while line = f2.gets
    if line =~ /thread_title/
        File.open('threads.txt', 'a') do |threads|
          threads.puts line
        end
    end
  end
end

### Create and initialize the array ###
i=1
threadlist=arraymen(50,50)
threadlist[0][0]=nil

### Fill the array with the titles and links from the file ###
File.open("threads.txt", 'r') do |threads|
  while line = threads.gets
	if @OS==1 ## WINDOWS ##
		title=line.scan(/\>([^*]+)\</).to_s
		link=line.scan(/"f([^.]+)\?/).to_s
		var=title.length - 6
		title=title[3,var]
		var=link.length - 6
		link=link[3,var]
    else
		title=line.scan(/\>([^*]+)\</)
		link=line.scan(/"f([^.]+)\?/)
    end
		threadlist[i][0]=title # scans for thread title
		threadlist[i][1]="http://tehparadox.com/forum/f#{link}"
	i=i+1
  end
end

### List all the threads in screen ###
i=1
while (threadlist[i][0]!=nil)
  puts "#{i} : #{threadlist[i][0]}"
  i=i+1
end
puts "select thread"
option=nil
optionint=0
option=gets().chomp
optionint=option.to_i

### get the url of the selected thread ###
url=threadlist[optionint][1]
page= agent.get(url)

### Parse the links from the thread ###

postBody = page.parser.xpath('/html/body/div[2]/div[3]/div[2]/div/div/table/tr[2]/td[2]/div').map do |row|

	postBodyRow=row.text.to_s

	if postBodyRow =~ /megaupload/
		 File.open('temp.txt', 'w') do |f|
		f.puts row.text
		end
		break
	end

end
### Clean up old Links.txt and insert new links into links.txt ###
File.open('links.txt', 'w') do |nothing|
end
File.delete('links.txt')
File.open('temp.txt', 'r') do |f2|
  while line = f2.gets
    if line =~ /megaupload/
        File.open('links.txt', 'a') do |links|
          links.puts line    
		  puts line
        end
    end
  end
end

### Clean up ###
File.delete('temp.txt')
File.delete('threads.txt')

