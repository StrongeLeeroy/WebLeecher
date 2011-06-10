require 'mechanize'
require 'digest'
class SearchesController < ApplicationController


  def arraymen(width,height)
      a = Array.new(width)
      a.map! { Array.new(height) }
      return a
  end

  def new
    @title = "Le Leecher"
  end

  def create
    username = params[:search][:forumuser]
    password = params[:search][:forumpass]
    session[:username] = username
    session[:password] = password
    forumchoice = params[:search][:forumchoice]
    query = params[:search][:forumquery]
    digest = Digest::MD5.hexdigest(password)
    agent = Mechanize.new
    page = agent.get("http://tehparadox.com/forum/index.php")
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

    page = agent.get("http://tehparadox.com/forum/search.php")
    @token=""
      ### Load the whole page ###
      troll = page.parser.xpath('/html').map do |row|
        test = row.text.to_s
        if test =~ /SECURITY/
            File.open('temp.txt','w') do |f|
              f.puts test
            end
            File.open('temp.txt', 'r') do |f|
              while line = f.gets
                if line =~ /SECURITY/
			            @token = line
                end
              end
            end
        end     
      ### Trim the string to just the actual token ###
	    @token = @token.scan(/\"([^.]+)\"/).to_s
      end

    
    securitytoken = @token

    if securitytoken != "guest"
      ### Load the search form ###
      search_form = agent.page.form_with(:action => 'search.php?do=process')
      ### Populate the search form ###
      childforums2 = 1
      prefixchoice2 = "MU"


      ### Complete search form with data and token ###
      search_form['query'] = query
      search_form['titleonly'] = 1
      search_form['forumchoice[]'] = forumchoice
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
      i = 1
      @threadlist = arraymen(50,50)
      @threadlist[0][0] = nil

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
		      @threadlist[i][0]=title # scans for thread title
		      @threadlist[i][1]="http://tehparadox.com/forum/f#{link}"
	        i = i + 1
        end
      end


      @searchquery = { :username => username, :password => password, :forumchoice => forumchoice, :query => query }
      render 'update'
    else
      flash.now[:error] = "Login data was incorrect."
      @title = "Le Leecher"
      render 'new'
    end
  end



  def update
    username = session[:username]
    password = session[:password]
    digest = Digest::MD5.hexdigest(password)
    agent = Mechanize.new
    page = agent.get("http://tehparadox.com/forum/index.php")
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

    ### Create and initialize the array ###
    i = 1
    threadlist = arraymen(50,50)
    threadlist[0][0] = nil

    ### Fill the array with the titles and links from the file ###
    File.open("threads.txt", 'r') do |threads|
      while line = threads.gets
		    title=line.scan(/\>([^*]+)\</)
		    link=line.scan(/"f([^.]+)\?/)
		    threadlist[i][0]=title # scans for thread title
		    threadlist[i][1]="http://tehparadox.com/forum/f#{link}"
	      i = i + 1
      end
    end
    threadchoice = params[:search][:threadchoice]
    

    optionint = 0
    optionint = threadchoice.to_i

    ### get the url of the selected thread ###
    url = threadlist[optionint][1]
    page = agent.get(url)

    ### Parse the links from the thread ###

    postBody = page.parser.xpath('/html/body/div[2]/div[3]/div[2]/div/div/table/tr[2]').map do |row|

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
            end
        end
      end
    end
    i = 0
    @linklist = Array.new
    
    File.open('links.txt', 'r') do |links2|
      while line = links2.gets
        @linklist << line
        i = i + 1
      end
    end


    render 'show'

  end

  def show
    @title = "Le Leecher Results"
  end

end
