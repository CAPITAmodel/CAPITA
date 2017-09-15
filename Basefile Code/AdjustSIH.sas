
**************************************************************************************
* Program:      AdjustSIH.sas                                                        *
* Description:  Makes any required adjustments to the SIH datasets.                  *                                                            
**************************************************************************************;

* The person with SihHID = 8997485, SihFID = 2 and SihIUID = 1 is the only person in
  this income unit, but they have a IUPOS of 2 (partner of reference person). Since
  they are a single person, they cannot be a spouse, and hence their IUPOS needs to be
  reset to 1 ;

DATA SihPerson ;

    SET SihPerson ;

    IF IUPOS = 2 AND IUTYPEP = 4 THEN IUPOS = 1 ;

RUN ;





