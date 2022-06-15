---INSTALLING TESSA---

1. Download Tessa program files from GitHub
	These program files should include "Tessa (No Runtime).exe," an application installer that assumes the user 
	already has the MATLAB runtime installed, "Tessa (Runtime).exe," an application installer that comes bundled
	with the MATLAB runtime (recommended for those who have not previously installed MATLAB on their computers),
	and this readme file, "Tessa Readme.txt."
	
2. Double-click "Tessa.exe" or "MyAppInstaller_mcr.exe" to begin installation
	By default, Tessa's program files will be installed to C:\\Program Files\University of Delaware\Tessa.
	For ease of use, users may choose to create a desktop shortcut to Tessa's main program file during
	installation.
	
3. Install the MATLAB runtime
	Tessa requires certain basic MATLAB functions in order to function properly; these functions are contained
	within the MATLAB runtime files that the installation process will prompt users to create. Installation of
	runtime files must be performed only once.
	
4. IMPORTANT: Take note of Tessa's active file path
	MATLAB applications can only "see" files that are located within their active file paths. Which file path
	is active will depend on where the user launched Tessa from: for users who launched Tessa from a desktop
	shortcut, the active file path will typically be C:\\Users\[Your Username]\Desktop. For users who launched
	Tessa directly from its installation location, the active file path will typically be C:\\Program Files\
	University of Delaware\Tessa\Application. To determine the active file path of your current program instance, 
	you can click the "Browse" button under "1. Define location of 'partwise.dtd.'" The folder that the file 
	browser takes you to by default is the active folder. 
	
	TESSA WILL NOT FUNCTION IF THE FILES THAT YOU ARE TRYING TO ANALYZE ARE NOT IN ITS ACTIVE FILE PATH. For 
	best results, make it a habit to keep all of your analyzed files (.mxl, .xml, .mat, .dtd, etc.) in the same
	folder as the icon you use to launch Tessa, moving them to different folders for storage only once you have
	finished all of your analyses.

	If you have the full MATLAB program installed, you may choose to open Tessa.mlapp (rather than Tessa.exe) 
	at which point you will be able to manually load folders into the active file path.


---DOWNLOADING SHEET MUSIC AND PREPARING FOR CONVERSION---

1. Download sheet music
	Download sheet music in the open-source MusicXML format (file extension .mxl). Both musescore.com 
	and musicalion.com have a variety of sheet music in this format.

2. MusicXML libraries
	Download MusicXML libraries and definitions. These are available at 
	https://github.com/grame-cncm/libmusicxml/releases, and tell MATLAB how it is meant to interpret 
	the data contained within the sheet music files.

3. Notes about the .mxl format
	The MXL format is a compressed format that must be decompressed to a .xml for analysis. By far 
	the easiest way to do this is with Finale Notepad, a free version of the popular Finale music 
	notation software.

4. Import .mxl file into Finale Notepad
	In Finale Notepad, select ‘File → MusicXML → Import’ to import your .mxl file, or simply open it
	by double-clicking the file.
	
	IMPORTANT NOTE: After import, it is CRITICAL to check the score visually for errors, inconsistencies,
	and other mistakes. Tessa reads and analyzes the musical data contained within MusicXML files! It does
	not error check or “judge” the data in any way unless it is unable to parse or compile data from the file.
	
5. Export the compressed .mxl file to an uncompressed .xml file
	In Finale Notepad, select ‘File → MusicXML → Export’. Choose .xml as the output file format and save to 
	the desired directory.

6. Specify location of partwise.dtd
	MusicXML handles scores in two different ways: partwise and timewise. Partwise scores lay out all the 
	information in one musical part (Violin, Oboe, Soprano, etc.) before moving on to the next musical part. 
	Timewise scores lay out all the information for ALL parts in one measure before moving on to the next measure. 
	Tessa analyzes sheet music using the partwise definition. In order to parse the .xml file correctly, MATLAB 
	must be told where in users' file directories to look for the partwise.dtd file, which defines partwise scores. 
	This file can be found in the MusicXML Libraries in the "schema" folder.
	
		a. Rationale for changing partwise.dtd file path to local storage
			By default, MusicXML sheet music files “look for” partwise.dtd online. In instances where 
			internet access is not available, however, Tessa will throw an error when the program attempts 
			to contact the MusicXML server. It is easier and more consistent to change the XML sheet music 
			to “look for” partwise.dtd in locally stored MusicXML Libraries. 
			
		b. Copy file path of partwise.dtd
			Open Tessa. In the panel titled '1. Define location of partwise.dtd,' a button marked ‘Browse’ 
			will open up a file browser to locate partwise.dtd. Once users have navigated to partwise.dtd 
			and selected ‘Open,’ Tessa will automatically copy the file path to the clipboard.
			
		c. Open the .xml file you wish to analyze
			Open the target .xml sheet music file with an .xml editing application. Notepad++ is an excellent 
			freeware option on Windows operating systems. The following string of text will be written in 
			the second line of the .xml file:
				i. http://musicxml.org/dtds/partwise.dtd
				
		d. Replace string with local file path
			Select the above text string, not including quotation marks, and paste the file path on the 
			clipboard over the text string. The second line of the .xml file should now look like this, with 
			the ‘C:\Users\Documents…’ file path replaced by the specified file path.
				i.<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.0 Partwise//EN" 
				  "C:\Users\Documents\musicxml-3.1\schema\partwise.dtd">
				
		e. Save the .xml file
			Press Control+S to save the changes to the .xml sheet music file.
			

---CONVERTING .XML FILES TO .MAT FILES---

1. Specify a file output name in the text field
	Tessa's next step will be to convert the newly exported .xml file into a MATLAB variable with the file 
	extension .mat. Under ‘2. Convert .xml file to MATLAB structure,’ type the name that Tessa will save its
	analyses as.

		a. Examples: "Im wunderschonen Monat Mai," "Can't Help Lovin' That Man," or "A Little Priest."
	
2. Specify a .xml file to be converted
	Under ‘2. Convert .xml file to MATLAB structure,’ select ‘Browse and Convert.’ Navigate to and select 
	the decompressed, edited .xml file.
	
3. Wait for Tessa to convert the .xml file into a MATLAB structure array
	Specifying a .xml file to parse in Step 2 will immediately begin the process of converting that file 
	into a MATLAB structure array.
	
		NOTE: This step is the longest in Tessa's runtime. There will be no indication that Tessa is 
		running, but that only means that everything is going well! A file with the user-specified output
		name and the file extension .mat should appear within 1-2 minutes, depending on processing power 
		and the length of the piece selected for conversion.
		
		SECOND NOTE: It is not necessary to perform the steps in this section or the previous section 
		each time Tessa runs. Once the MATLAB structure array created in the conversion process is saved
		to the computer at the end of this step, users can begin all future analyses of that piece by 
		following the steps in the next section, Compiling Data from .Mat Files.
		
	
---COMPILING DATA FROM .MAT FILES---
	
1. Specify a Part ID
	In most voice-piano scores, the Part ID of the voice part is P1. In more complex orchestral scores, however, 
	the correct Part ID is determined by counting parts from the top of the score. If a voice part is the ninth 
	part from the top, its Part ID would be P9.

		NOTE: Naming conventions are incredibly important to Tessa: if the program knows to look for all the 
		information contained in the part marked "P1," it will ONLY look for information in parts marked "P1." 
		If users have entered "1" or "Part 1," Tessa won't know where to look for musical information. The name 
		entered here must be the letter P followed by a number!
	
2. Specify a tempo
	Tessa uses tempo for a variety of analyses; the program will fail to compile musical data unless users have
	specified a tempo. If pieces feature an abrupt shift in tempo partway through (e.g., in a cavatina/cabaletta 
	aria) it may be easiest to separate the MusicXML file into two parts, then analyze each separately. Future 
	updates may introduce tempo shift compatibility.

		NOTE: The MusicXML libraries often treat beat duration differently than musicians would: MusicXML treats
		a "beat" as the smallest unit of musical time present in the piece, whereas musicians look at the time
		signature for this information. If Tessa returns song durations that are out of proportion with the
		durations of recordings or performances of the piece, you may need to experiment with different tempo
		markings to approximate the correct tempo.
	
3. Compile data from MATLAB structure array
	Once users have entered a part ID and tempo, selecting "Browse and Compile" will cause Tessa to scan through 
	the MATLAB structure array, compiling data and running back-end analyses. After a few seconds, a new file 
	will appear in the active MATLAB file path that contains the name of the piece, the part ID, and the tempo.

		a. Example: "La ci darem la mano--P1--90 BPM.mat"
		
4. Verify the integrity of the compiled data
	Verifying the integrity of the data that Tessa compiles is essential! Tessa is extremely fast, compared to 
	hand calculation, but only operates under the strict parameters that it has been given. While I have made every
	effort to stress-test Tessa in order to stamp out bugs and glitches, it is likely that I have not managed to 
	eliminate all of them. Quickly scanning the minimum and maximum fundamental frequency values, checking the contour 
	of the melody in the Note-by-Note Tessitura tab, and visually reviewing the full_score, full_pitch_sort, 
	and unique_F0 variables (for users who are running Tessa in the main MATLAB program) for errors will help ensure 
	that the outputs Tessa returns are not faulty.

		NOTE: Once users are satisfied that their compiled data has the correct Part ID and tempo, and once 
		they have verified that the compiled MATLAB variables are accurate and complete, all future analyses 
		of that piece (at that specific tempo and in that specific part) can be conducted using Tessa's last 
		major function, displaying graphics and metrics. Browse to the finished .mat file 
		("Piece Name--Part ID--Tempo.mat") and Tessa will display all of its outputs across multiple tabs.


---DISPLAYING GRAPHICS AND METRICS---

1.	Perform analyses
	Four analysis tabs are available: ‘Global Tessitura Metrics,’ ‘Note-by-Note Tessitura Metrics,’ ‘Vocal Demand 
	Metrics,’ and ‘Summary Statistics.’
		
		a. Global Tessitura Metrics: global tessitura metrics are insensitive to the time course of a piece--that is,
		they convey information about a piece as a whole, not on a measure-by-measure basis. The 'Median, range, 
		and interquartile frequencies' axes object displays a box plot of the piece's frequency data, showing users
		the full range of fundamental frequencies as well as the middle 50%, or interquartile range, of frequencies. 
		The axes object 'Phonation time at each voiced frequency' displays a histogram that sums the duration of 
		voicing at each sung frequency throughout the piece.
		
		b. Note-by-Note Tessitura Metrics: note-by-note tessitura metrics show the melodic contour of a part in time.
		The default plot, a blue dotted line, shows the fundamental frequency values; as users adjust the slider marked 
		'Moving Average Weight,' a second plot, a solid red line, will appear. This plot shows the moving average of 
		a number of fundamental frequency values equal to the slider's value. As the slider's value decreases toward 1, 
		the red moving average plot will increasingly resemble the raw fundamental frequency data in blue; as the slider's 
		value increases toward 150, the contour will become progressively "smoothed." Users can experiment with moving 
		average slider values to determine which values best capture the melodic contour of the piece.
		
		c. Vocal Demand Metrics: percent time spent voicing, total vocal fold cycles, and mean vocal fold cycles 
		per second are all indices of phonatory dose. As these metrics rise, the vocal folds will generally contact 
		each other more often, and the singer will have fewer opportunities to rest in between periods of voicing. 
		These metrics may therefore estimate "how big of a sing" a piece is.
		
		d. Summary Statistics: for users who prefer simple numerical outputs, rather than graphical outputs, the 
		summary statistics tab displays many of the outputs found in the other three tabs in numerical form.