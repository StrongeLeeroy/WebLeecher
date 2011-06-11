#WebLeecher ALPHA v0.3.0

New Ruby scripts by [Revy](mailto:revy@lethalia.net) in place.

App is about 80% functional, only working while in localhost.

[MU] link extraction achieved in almost every case.


##Alpha Releases:

*   v0.3.1 Alpha (Beta candidate)
    -   Simplified the forum category picker using a select_tag
    -   Fixed the bad URI bug.
    -   BETA Candidate.

*   v0.3.0 Alpha
    -   Reworked the whole parsing code so that the app is not dependant of .txt files.
    -   Major interface changes.
    -   Parsed links now are presented inside a "code-box" for simplified selecting.

*   v0.2.0 Alpha
    -   Sessions are now being used to avoid having to input login data twice.
    -   Links are now correctly parsed and written in the show.html.erb view.	
    -   Mostly functional, still getting errors when HREFs contains special characters (bad URI).

*   v0.1.0 Alpha
    -   Initial ALPHA release.
    -   Threadlist is correctly parsed and written to update.tml.erb.
    -   Link are still not being correctly parsed. Possibly a problem with HTMLs staticness.
