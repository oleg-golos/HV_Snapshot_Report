# HV_Snapshot_Report
The script generates report on all Hyper-V snapshots across the AD domain and sends it to a specified email.
* It relies on Invoke-Parallel script for parallelism (https://gallery.technet.microsoft.com/scriptcenter/Run-Parallel-Parallel-377fd430). Copy of Invoke-Parallel is included and must be placed in the same folder as the main script.
* It assumes all of your Hyper-V servers contain "HV" in their names. If it's not the case for you, please modify $filter variable accordingly.
* It will ignore snapshots containing "ExcludeFromReport" in their names. Feel free to modify $excl variable if you want to use something else as an exclusion tag.
* It will ignore snapshots that are newer than two days. Minimum age can be adjusted via $MinSnapAge variable.
