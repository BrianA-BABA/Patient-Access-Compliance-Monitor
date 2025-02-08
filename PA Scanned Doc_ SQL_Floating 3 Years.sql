SELECT *
FROM (
    SELECT --TOP 10000
        livendb.dbo.BarVisits.AccountNumber,
        livendb.dbo.BarVisits.VisitID,
        livendb.dbo.AdmittingData.ArrivalID,
        livendb.dbo.BarVisits.UnitNumber,
        livendb.dbo.BarVisitFinancialData.AccountType,
        CASE
            WHEN (livendb.dbo.BarVisits.InpatientOrOutpatient = 'I') THEN livendb.dbo.AdmVisits.LocationID
            ELSE livendb.dbo.BarVisits.OutpatientLocationID
        END AS 'Service/Location',
        --livendb.dbo.BarVisits.DischargeDispositionID,
         livendb.dbo.BarVisits.PrimaryInsuranceID,
        livendb.dbo.BarVisits.FinancialClassID,
        IIF(CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101) IS NULL,
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.AdmitDateTime, 101),
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101)) AS 'Adm/Reg',
        IIF(CONVERT(VARCHAR(10), livendb.dbo.BarVisits.DischargeDateTime, 101) IS NULL,
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101),
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.DischargeDateTime, 101)) AS 'Depart/Dis',
            livendb.dbo.DMisDischargeDisposition.Name AS DischargeDisposition,
            --[livefdb].[dbo].[HimScaDoc_Main].[Person_UnvUserID],
           -- IIF([livendb].[dbo].[DMisUsers].[Name] IS NULL, 'SYSTEM', [livendb].[dbo].[DMisUsers].[Name] ) AS UserName,
        CASE WHEN livefdb.dbo.MisMrd_Main.Name IS NOT NULL THEN livefdb.dbo.MisMrd_Main.Name ELSE 'No Documents Found'END AS 'Name',
        CASE
         WHEN livefdb.dbo.MisMrd_Main.Name IS NOT NULL THEN IIF([livendb].[dbo].[DMisUsers].[Name] IS NULL, 'SYSTEM', [livendb].[dbo].[DMisUsers].[Name] ) 
         ELSE 'No Files Scanned' END AS Answer
        
    FROM livendb.dbo.BarVisits
    LEFT JOIN livendb.dbo.BarVisitFinancialData ON livendb.dbo.BarVisits.VisitID = livendb.dbo.BarVisitFinancialData.VisitID
    LEFT JOIN livendb.dbo.AdmVisits ON livendb.dbo.BarVisits.VisitID = livendb.dbo.AdmVisits.VisitID
    LEFT JOIN livendb.dbo.AdmittingData ON livendb.dbo.BarVisits.VisitID  = livendb.dbo.AdmittingData.VisitID
    LEFT JOIN livefdb.dbo.HimSca_Docs ON livendb.dbo.BarVisits.VisitID = livefdb.dbo.HimSca_Docs.VisitID
        AND (
            livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'MOON/NOON' OR livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'MCRIMFORM' OR
            livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'PATIENT RIGHTS' OR livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'NYSAPLFRM' OR
            livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'DEATH' OR livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'CONSENT' OR 
            livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID ='ACS' OR livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'ID' OR 
            livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'INS.CRD' OR livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = 'HLTHXGRNT'

            )
    LEFT JOIN livefdb.dbo.MisMrd_Main ON livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID = livefdb.dbo.MisMrd_Main.MisMrdID
    LEFT JOIN livefdb.dbo.HimScaDoc_Main ON livefdb.dbo.HimSca_Docs.Document_HimScaDocID = livefdb.dbo.HimScaDoc_Main.HimScaDocID
    AND livefdb.dbo.HimScaDoc_Main.FormIdentifier_MisMrdID = livefdb.dbo.HimSca_Docs.DocumentIdentifier_MisMrdID
    LEFT JOIN livendb.dbo.DMisUsers ON livefdb.dbo.HimScaDoc_Main.SourceID = livendb.dbo.DMisUsers.SourceID
    AND livefdb.dbo.HimScaDoc_Main.Person_UnvUserID = livendb.dbo.DMisUsers.UserID
    LEFT JOIN livendb.dbo.AdmDischargeInfo ON livendb.dbo.BarVisits.VisitID = livendb.dbo.AdmDischargeInfo.VisitID
    LEFT JOIN livendb.dbo.DMisDischargeDisposition ON livendb.dbo.BarVisits.SourceID = livendb.dbo.DMisDischargeDisposition.SourceID
    AND livendb.dbo.BarVisits.DischargeDispositionID = livendb.dbo.DMisDischargeDisposition.DispositionID

    WHERE 
--livendb.dbo.BarVisits.AccountNumber = 'V00221585235'
    (
        IIF
            (livendb.dbo.BarVisits.AdmitDateTime IS NULL,
            livendb.dbo.BarVisits.ServiceDateTime,
            livendb.dbo.BarVisits.AdmitDateTime) 
            BETWEEN DATEADD(year, DATEDIFF(year, 0, GETDATE())-1, 0) AND CONVERT(date, GETDATE())
        )

        --AND livendb.dbo.BarVisits.FinancialClassID = 'MCR'

        AND livendb.dbo.BarVisitFinancialData.AccountType IN ('O ER', 'O OBS', 'I INP')
GROUP BY 
 livendb.dbo.BarVisits.AccountNumber,
        livendb.dbo.BarVisits.VisitID,
        livendb.dbo.AdmittingData.ArrivalID,
        livendb.dbo.BarVisits.UnitNumber,
        livendb.dbo.BarVisits.DischargeDispositionID,
        livendb.dbo.BarVisitFinancialData.AccountType,
    livendb.dbo.BarVisits.InpatientOrOutpatient,
            livendb.dbo.AdmVisits.LocationID,
            livendb.dbo.BarVisits.OutpatientLocationID,
            livendb.dbo.BarVisits.PrimaryInsuranceID,
        livendb.dbo.BarVisits.FinancialClassID,
        IIF(CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101) IS NULL,
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.AdmitDateTime, 101),
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101)),
        IIF(CONVERT(VARCHAR(10), livendb.dbo.BarVisits.DischargeDateTime, 101) IS NULL,
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.ServiceDateTime, 101),
            CONVERT(VARCHAR(10), livendb.dbo.BarVisits.DischargeDateTime, 101)),
            livendb.dbo.DMisDischargeDisposition.Name,
            livefdb.dbo.HimScaDoc_Main.Person_UnvUserID,
            livendb.dbo.DMisUsers.Name,
         livefdb.dbo.MisMrd_Main.Name 
) AS PivotData
PIVOT (
    MAX(Answer)
    FOR Name IN ([Medicare IM Form], [MOON/NOON Form], [PATIENT RIGHTS], [NYS APPEAL FORM], [DEATH INFORMATION], [CONSENT],[AMBULANCE CALL SHEET], [PHOTO ID], [INSURANCE CARD], [No Documents Found], [HEALTHIX CONSENT GRANTED]) -- Replace [Name1], [Name2], [Name3] with actual names
) AS PivotTable;
