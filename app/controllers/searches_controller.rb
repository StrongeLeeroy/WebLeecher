require 'mechanize'
require 'digest'
require 'uri'
class SearchesController < ApplicationController

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
    dologin(session[:username], session[:password], session[:digest], agent)

    page = agent.get("http://tehparadox.com/forum/search.php")
    gettoken(page)
    
    securitytoken = @token

    if securitytoken != "guest"
      dosearch(session[:query], session[:forumchoice], session[:prefixchoice], securitytoken, agent, page)
      render 'update'
    else
      flash.now[:error] = "Login data was incorrect."
      @title = "Le Leecher"
      render 'new'
    end
  end



  def update
    @threadchoice = params[:search][:threadchoice]
    agent = Mechanize.new
    dologin(session[:username], session[:password], session[:digest], agent)

    url = ""
    url = @threadchoice
    URI.parse(url.gsub(/ /, '+'))
    page = agent.get(url)
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

  def show
    if params[:search][:threadchoice].nil?
      render 'new'
    else
      @title = "Le Leecher Results"
    end
  end

end