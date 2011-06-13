require 'mechanize'
require 'digest'
require 'uri'
class SearchesController < ApplicationController


  def arraymen(width,height)
      a = Array.new(width)
      a.map! { Array.new(height) }
      return a
  end

  def new
    @title = "Le Leecher"
  end

  def reset
    @title = "Le Leecher"
    render 'new'
  end

  def create
    prefix = params[:prefixchoice]
    username = params[:search][:forumuser]
    password = params[:search][:forumpass]
    forumchoice = params[:forumchoice]
    query = params[:search][:forumquery]

    session[:prefixchoice] = prefix
    session[:username] = username
    session[:password] = password
    session[:query] = query
    session[:forumchoice] = forumchoice

    ### Load login form ###
    agent = Mechanize.new
    page = agent.get("http://tehparadox.com/forum/index.php")
    login_form = agent.page.form_with(:action => 'http://tehparadox.com/forum/login.php?do=login')
    ### Populate the login form ###
    digest = Digest::MD5.hexdigest(password)

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
    @token = ""
    ### Load the whole page ###
    troll = page.parser.xpath('/html').map do |row|    
      leech = row.text.match(/Sec([^v]+)"/i)
      leech = leech.to_s
      ### Trim the string to just the actual token ###
      @token = leech.scan(/\"([^.]+)\"/).to_s
    end
    
    securitytoken = @token

    if securitytoken != "guest"
      ### Load the search form ###
      search_form = agent.page.form_with(:action => 'search.php?do=process')
      ### Populate the search form ###
      child = 1
      #system('cls')

      ### Complete search form with data and token ###
      search_form['query'] = query
      search_form['titleonly'] = 1
      search_form['forumchoice[]'] = forumchoice
      search_form['childforums'] = child
      search_form['prefixchoice[]'] = prefix
      search_form['s'] = ""
      search_form['securitytoken'] = securitytoken
      search_form['do'] = "process"
      search_form['searchthreadid'] = ""
      ### submit the search form ###
      page = agent.submit search_form

      ### Create and initialize the array ###
      i=1
      @threadlist = arraymen(50,50)
      @threadlist[0][0] = nil

      page.links.each do |link|
        if link.text.match(/#{session[:query]}/i)
        ### Fill the array with the titles and links from the file ###
          @threadlist[i][0] = link.text # scans for thread title
          @threadlist[i][1] = "http://tehparadox.com/forum/#{link.href}"
          i=i+1
        end
      end
      render 'update'
    else
      flash.now[:error] = "Login data was incorrect."
      @title = "Le Leecher"
      render 'new'
    end
  end



  def update
    if session[:username] == nil
      redirect_to 'new'
    else
      username = session[:username]
      password = session[:password]
      query = session[:query]
      forumchoice = session[:forumchoice]
      threadchoice = params[:search][:threadchoice]
      prefix = session[:prefixchoice]

      agent = Mechanize.new
      page = agent.get("http://tehparadox.com/forum/index.php")
      login_form = agent.page.form_with(:action => 'http://tehparadox.com/forum/login.php?do=login')
      ### Populate the login form ###
      digest = Digest::MD5.hexdigest(password)

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
      @token = ""
      ### Load the whole page ###
      troll = page.parser.xpath('/html').map do |row|    
        leech = row.text.match(/Sec([^v]+)"/i)
        leech = leech.to_s
        ### Trim the string to just the actual token ###
        @token = leech.scan(/\"([^.]+)\"/).to_s
      end
      
      securitytoken = @token
      ### Load the search form ###
      search_form = agent.page.form_with(:action => 'search.php?do=process')
      ### Populate the search form ###
      child = 1
      #system('cls')

      ### Complete search form with data and token ###
      search_form['query'] = query
      search_form['titleonly'] = 1
      search_form['forumchoice[]'] = forumchoice
      search_form['childforums'] = child
      search_form['prefixchoice[]'] = prefix
      search_form['s'] = ""
      search_form['securitytoken'] = securitytoken
      search_form['do'] = "process"
      search_form['searchthreadid'] = ""
      ### submit the search form ###
      page = agent.submit search_form

      ### Create and initialize the array ###
      i=1
      threadlist = arraymen(50,50)
      threadlist[0][0]=nil

      page.links.each do |link|
        if link.text.match(/#{session[:query]}/i)
        ### Fill the array with the titles and links from the file ###
          threadlist[i][0] = link.text # scans for thread title
          threadlist[i][1] = "http://tehparadox.com/forum/#{link.href}"
          i=i+1
        end
      end

      ### Create and initialize the array ###
      i=1
      threadlist = arraymen(50,50)
      threadlist[0][0] = nil

      page.links.each do |link|
        if link.text.match(/#{session[:query]}/i)
        ### Fill the array with the titles and links from the file ###
          threadlist[i][0] = link.text # scans for thread title
          threadlist[i][1] = "http://tehparadox.com/forum/#{link.href}"
          i=i+1
        end
      end

      ### Parse the links from the thread ###

      option = nil
      optionint = 0
      optionint = threadchoice.to_i
      url = ""
      ### get the url of the selected thread ###
      url = threadlist[optionint][1]
      url = URI.encode(url)
      page = agent.get(url)
      ### Parse the links from the thread ###
      @linklist = Array.new
      @links = Array.new
      postBody = page.parser.xpath('/html/body/div[2]/div[3]/div[2]/div/div/table/tr[2]/td[2]/div').map do |row|
        strong = row.to_s
        strong = strong.split(" ")
        i=0
        while (strong[i]!=nil)
          if strong[i] =~ /megaupload/
             line = strong[i].match(/\h([^<]+)/)
             @linklist << line
             @links << line
             @links << " "
          end
          i=i+1
        end
      end
      @links = @links.to_s
      render 'show'
    end
  end

  def show
    if params[:search][:threadchoice].nil?
      render 'new'
    else
      @title = "Le Leecher Results"
    end
  end

end
