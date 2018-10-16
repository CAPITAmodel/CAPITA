
**************************************************************************************
* Program:      DefineCapitaDirectory.sas                                            *
* Description:  Specifies the directory at which CAPITA is stored. Note that the     *
*               folder structure must be maintained as the directories referenced    *
*               in the CAPITA modules are all defined off this central directory     *
*               specification. Also, note that this module is called at the top of   *
*               each of the main CAPITA run programs (i.e. RunCAPITA,                *
*               RunCAPITACompare, RunParameters, Cameo Code, EMTR) so this will      *
*               usually not be required to be run separately.                        *
**************************************************************************************;

%LET CapitaDirectory = \\CAPITAlocation\ ;
