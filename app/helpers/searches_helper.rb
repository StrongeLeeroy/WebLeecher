require 'mechanize'
require 'digest'
require 'uri'
module SearchesHelper

  def arraymen(width, height)
      a = Array.new(width)
      a.map! { Array.new(height) }
      return a
  end

  def dologin(username, password, digest, agent)
    page = agent.get("http://tehparadox.com/forum/index.php")
    login_form = agent.page.form_with(:action => 'http://tehparadox.com/forum/login.php?do=login')
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
  end

  def dosearch(query, forumchoice, prefixchoice, securitytoken, agent, page)
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
    search_form['prefixchoice[]'] = prefixchoice
    search_form['s'] = ""
    search_form['securitytoken'] = securitytoken
    search_form['do'] = "process"
    search_form['searchthreadid'] = ""
    ### submit the search form ###
    page = agent.submit search_form
    
    i=1
    @threadlist = arraymen(50,50)
    @threadlist[0][0] = nil

    page.links.each do |link|
      if link.text.match(/#{query}/i)
      ### Fill the array with the titles and links from the file ###
        @threadlist[i][0] = link.text # scans for thread title
        @threadlist[i][1] = "http://tehparadox.com/forum/#{link.href}"
        i=i+1
      end
    end
    return @threadlist
  end

  def gettoken(page)
      @token = ""
      ### Load the whole page ###
      troll = page.parser.xpath('/html').map do |row|    
        leech = row.text.match(/Sec([^v]+)"/i)
        leech = leech.to_s
        ### Trim the string to just the actual token ###
        @token = leech.scan(/\"([^.]+)\"/).to_s
      end
  end

  def mirror(provider)
    if provider == "MU"
      return "megaupload"
    elsif provider == "RS"
      return "rapidshare"
    elsif provider == "HF"
      return "hotfile"
    elsif provider == "x7"
      return "x7"
    elsif provider == "NL"
      return "netload"
    elsif provider == "MS"
      return "megashares"
    elsif provider == "SM"
      return "filesonic"
    elsif provider == "MF"
      return "mediafire"
    elsif provider == "FF"
      return "filefactory"
    elsif provider == "DL"
      return "duckload"
    elsif provider == "FS"
      return fileserve
    elsif provider == "UL"
      return "uploading"
    elsif provider == "DF"
      return "depositfiles"
    elsif provider == "FTP"
      return //
    elsif provider == "Other"
      return //
    elsif provider == "Multi"
      return //
    elsif provider == ""
      return //
    elsif provider == "-1"
      return //
    end
  end

  def clippy(text, bgcolor='#FFFFFF')
    <<-EOF.html_safe
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
end