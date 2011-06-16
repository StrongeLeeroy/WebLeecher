require 'mechanize'
require 'digest'
require 'uri'
require 'dlc'
require 'active_support/secure_random'
class SearchesController < ApplicationController

  def new
    @title = "Le Leecher"
  end



  def create
    session[:username] = params[:search][:forumuser]
    session[:password] = params[:search][:forumpass]
    session[:query] = params[:search][:forumquery]
    session[:forumchoice] = params[:forumchoice]
    session[:prefixchoice] = params[:prefixchoice]
    session[:dlc] = params[:search][:dlc]

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
    session[:threadchoice] = @threadchoice
    agent = Mechanize.new
    dologin(session[:username], session[:password], session[:digest], agent)
    @dlc = session[:dlc]
    a = mirror(session[:prefixchoice])

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
        if strong[i] =~ /#{a}/
           line = strong[i].match(/\h([^<]+)/)
           @linklist << line
           @links << line
           @links << " "
        end
        i=i+1
      end
    end
    @links = @links.to_s
    if @dlc != "0"
      @p = DLC::Package.new
      i = 0
      while (@linklist[i]!=nil)
        @p.add_link("#{@linklist[i]}") 
        i = i + 1
      end
      session[:dlcname] = SecureRandom.hex(13) + ".dlc"
      open("tmp/#{session[:dlcname]}","w") do |f|
        f.write @p.dlc
      end
    end
    render 'show'
  end



  def show
    if params[:search][:threadchoice].nil?
      render 'new'
    else
      @title = "Le Leecher Results"
    end
  end



  def download
    @filename ="tmp/#{session[:dlcname]}"
    send_file(@filename, :filename => "#{session[:dlcname]}", :stream => false)
  end



end