''
' Instantiate an SavedSites object suitable for persistent storage of past site URLs
' @return - Object - A new SavedSites object
''
function newSavedSites() as Object
	savedSites = createObject( "roAssociativeArray" )
	savedSites.getSavedSites = savedGetSavedSites
	savedSites.addToSavedSites = savedAddToSavedSites
	savedSites.renderScreen = savedRenderScreen
	savedSites.implodeItems = savedImplodeItems
	savedSites.explodeItems = savedExplodeItems
	savedSites.cleanUp = savedCleanUp

	'Populate the object's internal list of sites using saved data
	savedSites.registry = createObject( "roRegistrySection", "browserData" )
	if savedSites.registry.exists( "history" )
		savedHistory = savedSites.registry.read( "history" )
		savedSites.sites = savedSites.explodeItems( savedHistory )
	else
		savedSites.sites = [ 
			"https://www.roku.com/",
			"http://www.poprism.com", 
			"https://www.reddit.com",
			"http://www.fbi.gov/",
			"http://www.rd.com/jokes/"]
	end if

	return savedSites
end function

''
' Get the most recent sites in FIFO order
' @return Array - Array of URL strings
''
function savedGetSavedSites() as Dynamic
	return m.sites
end function

''
' Add a site to the saved sites list
' @param - String - The URL to add
''
function savedAddToSavedSites( url ) as Void
	if url = ""
		return
	end if

	m.sites.unshift(url)

	while m.sites.count() > 5
		m.sites.pop()
	end while
end function

''
' Implode an array into a CSV
' @param - Array of strings
' @return - String - CSV of input array elements
''
function savedImplodeItems( items ) as String
	imploded = ""

	for each item in items
		imploded = imploded + item + ","
	end for

	return imploded
end function

''
' Explode a CSV into an array
' @param - String - CSV
' @return - Array - Array of strings
''
function savedExplodeItems( items ) as Dynamic
	return items.tokenize(",")
end function

''
' Render a screen that lets the user choose to make a new URL or use a saved URL
' @return - String - Either a saved URL or the phrase "Enter new URL"
''
function savedRenderScreen() as String
	sites = m.getSavedSites()
	siteList = [{ title: "Enter new URL", id: 0}]
	numSites = sites.count()

	for i = 0 to numSites-1 step 1
		siteList.push( { title: sites[i], id: i.toStr() } )
	end for

    	screen = CreateObject( "roListScreen" )
    	port = CreateObject( "roMessagePort" )
    	screen.SetMessagePort( port )
    	screen.SetContent( siteList )
    	screen.show()

   	 while ( true )
        	msg = wait( 0, port )

        	if ( type( msg ) = "roListScreenEvent" )
            		if ( msg.isListItemSelected() )
                		return siteList[ msg.GetIndex() ].title           
            		endif            
        	endif
    	end while
end function

''
' Save the sites in the object in memory
''
function savedCleanUp() as Void
	saveable = m.implodeItems( m.sites )
	m.registry.write( "history", saveable )
	m.registry.flush()
end function
