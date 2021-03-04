#!!!This is the only bit you need to change (more or less)!!!!
$csvpath = 

##If you don't know what all the stuff is below then you really don't need to worry about it :)

#Import the data
$data = Import-Csv -Path $csvpath

#A list of the courses we are interested in (this will need to be updated now and again)
$courses = ("Air Cadets - ACTO 10",
"Air Cadets - Security Brief (staff)",
"Fire Training 2020",
"Health, Safety & Enviroment Training 2020",
"Responsible for Information General User - 2020",
"Mandatory Training: Safeguarding Children Induction",
"Mandatory Training: Safeguarding Children Refresher")

#Throw away some of the columns and sort the data based on the Learner property
$data = $data | Select-Object -Property "Learner", "Course", "Completion Status", "Success Status", "Last Accessed" | Sort-Object -Property Learner

#Get a list of the staff members
$staff = $data.Learner | Sort-Object -Unique | Out-GridView -OutputMode Multiple -Title "Muti select (Ctrl + left click) the staff on your unit"

#Kick out a personalised list per staff member
foreach($staffmember in $staff){
$data | Where-Object -Property Learner -EQ $staffmember | Where-Object -Property "Course" -In $courses | Select-Object -Property "Course", "Completion Status", "Success Status", "Last Accessed" | Export-Csv -Path "$env:HOMEDRIVE$env:HOMEPATH\Desktop\$staffmember.csv" -Append -NoTypeInformation
}

#Now take all that data and put it together in one super awesome table
$fancytable = [System.Collections.ArrayList]::new()

foreach($staffmember in $staff){
    $myobj = New-Object -TypeName PSCustomObject
 
    Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Staff member' -Value $staffmember
    foreach($course in $courses){
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name $course -Value ($data | Where-Object -Property Learner -EQ $staffmember | Where-Object -Property "Course" -eq $course).'Completion Status'
    }

    $fancytable.Add($myobj) | Out-Null
}

$fancytable | Export-Csv -Path "$env:HOMEDRIVE$env:HOMEPATH\Desktop\StaffOverview.csv" -NoTypeInformation