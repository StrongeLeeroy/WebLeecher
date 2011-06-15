#WebLeecher BETA v0.4

The Ruby code behind the App is being developed by [Revy](mailto:revy@lethalia.net).

The Rails port and web interface are being worked out by [Leeroy](mailto:leeroy@lethalia.net).



##Beta Releases:

*   v0.4.1 Beta
    -   Initial Search submit form (new.html.erb) has been redesigned for a easier and more intuitive design.
    -   A link to the origin thread has been added to the Results page (show.html.erb) for convenience (ex: To check if there is a password to the file).
    -   About page has been updated and styled.
    -   Minor styling (font styling for the most part).



*   v0.4.0 Beta
    -   Bad URI code was being cause by the 35 second limit between searches. To avoid this, the
        thread links have been added to the values in the update.html.erb so that two forum searches
        are not performed per actual search, improving performance at the same time.
    -   The first thread in the update.html.erb view is now selected by default to avoid server side
        errors.
    -   Minor styling.

##Alpha Releases:

*   v0.3.3 Alpha (Beta candidate)
    -   The thread selection page now lets the user check a "radio button" rather than having to
	    type the thread number in a text box.
    -   Almost done migrating code chunks to the searches_helper file.


*   v0.3.2 Alpha (Beta candidate)
    -   Users may now choose the thread prefix through a dropdown select_tag.
    -   A "Copy to clipboard!" button has been added to the result show.html.erb page
	    for convenience.
    -   Forum category picker now works the way it should (no multiple choice functionality yet).
    -   Some minor styling.
    -   Added this README to the about.html.erb file.
    -   Will release BETA as soon as a few minor bugs are gone.


*   v0.3.1 Alpha (Beta candidate)
    -   Simplified the forum category picker using a select_tag
    -   Fixed the bad URI bug.
    -   A "Reset all fields" button has been added to the initial form in new.html.erb for
	    convenience.
    -   BETA Candidate.

*   v0.3.0 Alpha
    -   Reworked the whole parsing code so that the app is not dependant of .txt files.
    -   Major interface changes.
    -   Parsed links now are presented inside a "code-box" for easier selecting.

*   v0.2.0 Alpha
    -   Sessions are now being used to avoid having to input login data twice.
    -   Links are now correctly parsed and written in the show.html.erb view.	
    -   Mostly functional, still getting errors when HREFs contains special characters (bad URI).

*   v0.1.0 Alpha
    -   Initial ALPHA release.
    -   Threadlist is correctly parsed and written to update.html.erb.
    -   Link are still not being correctly parsed. Possibly a problem with HTMLs staticness.
