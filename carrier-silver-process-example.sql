WITH tmo1 AS (
SELECT *,
  GREATEST(MonthlyAccess, OriginalTotalMRC) AS MRC,
  Spiff+Commission AS Comp,
FROM `raw_input.tmobile_upfront_raw`
)

SELECT  
    -- Main Cols
    PARSE_DATE('%Y %m', LEFT(Month, 7)) AS RecordDate,
    UPPER(CustomerName) AS Customer,
    SAFE_CAST(BAN AS STRING) AS BAN,
    ActivityType,
    
    -- IDs
    DealerCode SPID,
    ServiceUniversalID as SUID,
    ServiceNumber,

    -- Dates
    Month,
    CheckNumber,
      CASE 
        WHEN CheckNumber like '%ALL' then 'ALL'
        WHEN CheckNumber like '%AJ%' then 'AJ'
        END AS CheckType,
    safe_cast(ActDate AS DATE) AS ActDate,
    safe_cast(DeactDate AS DATE) AS DeactDate,
    #safe_cast(ReactDate AS DATE) AS ReactDate, #- not comped

    -- Misc
    ProductType AS AddType,
    PlanCode,
    ProdCatDescription,
    NonCommissionableReason,

    -- Commission
    CASE 
      WHEN Comp > 0 THEN 1
      WHEN Comp < 0 THEN -1
      ELSE 0
      END AS Qty,
    MRC,
    Comp AS Commission,
    ROUND(SAFE_DIVIDE(Comp,MRC), 1) AS EffectiveRate, 

    -- Tags
    'tmobile_upfront' AS DataSource,
    UploadDate,

FROM tmo1
-- Filtering out $0 lines.
WHERE Comp <> 0

ORDER BY RecordDate NULLS LAST
