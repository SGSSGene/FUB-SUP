layout of a module unit in version 1
```
# document format version
formatversion: 1

# Title of the module, in Module description it is prepended with "Module:"
name: "Name of the module"

# !TODO: Not sure what this is, in Module description it is prepended with "Hochschule/Fachbereich/Lehreinheit:"
organizer: "Freie Universität Berlin/Mathematik und Informatik/Informatik"

# Who is responsible for this module, in Module description this is prepended with "Modulverantwortung:"
responsible: "Dozent*in des Moduls gemäß der Zuordnungsliste bei dem*der Studiengangsverantwortlichen"

# Requirements
requirements: "Keine"

# "Qualifikationsziele", qualifikation the students should have after passing this module
goals: |
    This might
    be some longer text

# "Inhalte", content of the course
content: |
    This might
    be some longer text
# Each module consist of multiple teaching units, like "Vorlesung" and "Übung"
teachingunit:
    # type of the teaching unit
    - type: Vorlesung
    # time (in SWS units 1 SWS ~ 15h per Semester) that should be spend during the semester on this part
      swstime: 4
    # If attendance is required, or recommended
      attendance: "required"
    # If, and How active participation is being achieved
      activity: "By handing in all exercises"

# Modulprüfung: what type of exam
exam: |
    Some text, describing the exam
# Language of the course
language: Deutsch

# How many hours of work for students, this module is designed for
total_work: 270

# Amount of creditpoints (Leistungspunkte) students get for successfully passing this modul
credit_points: 9

# Duration this module is designed for
duration: "Ein Semester"

# How often this is being offered
repeat: "Jedes Wintersemester"

# Hints on where this module fits into different "studiengänge"
usability: |
    Bachelorstudiengang Informatik, Bachelorstudiengang Informatik für
    das Lehramt, Bachelorstudiengang Bioinformatik, Einführungs- und
    Orientierungsstudium, 30-Leistungspunkte-Modulangebot Informatik
    im Rahmen anderer Studiengänge, 60-Leistungspunkte-Modulangebot Informatik im Rahmen anderer Studiengänge, Masterstudiengang für das Lehramt an Integrierten Sekundarschulen und Gymnasien, Masterstudiengang für das Lehramt an Integrierten Sekundarschulen und Gymnasien mit dem Profil Quereinstieg, Masterstudiengang Wirtschaftsinformatik, Masterstudiengang Computational
```
