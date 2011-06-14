require 'mechanize'
require 'digest'
require 'cgi'
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
    
    session[:username] = params[:search][:forumuser]
    session[:password] = params[:search][:forumpass]
    session[:query] = params[:search][:forumquery]
    session[:forumchoice] = params[:forumchoice]
    session[:prefixchoice] = params[:prefixchoice]

    session[:digest] = Digest::MD5.hexdigest(session[:password])
    agent = Mechanize.new
    ### Load login form ###
    
    ### Populate the login form ###
    dologin(session[:username], session[:password], session[:digest], agent)

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
      
      dosearch(session[:query], session[:forumchoice], session[:prefixchoice], securitytoken, agent, page)
      ### Load the search form ###
      search_form = agent.page.form_with(:action => 'search.php?do=process')
      ### Populate the search form ###
      child = 1
      #system('cls')

      ### Complete search form with data and token ###
      search_form['query'] = session[:query]
      search_form['titleonly'] = 1
      search_form['forumchoice[]'] = session[:forumchoice]
      search_form['childforums'] = child
      search_form['prefixchoice[]'] = session[:prefixchoice]
      search_form['s'] = ""
      search_form['securitytoken'] = securitytoken
      search_form['do'] = "process"
      search_form['searchthreadid'] = ""
      ### submit the search form ###
      page = agent.submit search_form
      return page
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
    if session[:username].nil?
      redirect_to 'new'
    else
      agent = Mechanize.new
      
      dologin(session[:username], session[:password], session[:digest], agent)

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
      search_form['query'] = session[:query]
      search_form['titleonly'] = 1
      search_form['forumchoice[]'] = session[:forumchoice]
      search_form['childforums'] = child
      search_form['prefixchoice[]'] = session[:prefixchoice]
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
      optionint = session[:threadchoice].to_i
      url = ""
      ### get the url of the selected thread ###
      url = threadlist[optionint][1]
      url = URI.parse(URI.encode(url))
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
