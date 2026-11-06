USE [Charcoal_Inventory_Analytics];
GO

ALTER TABLE [dbo].[FactPurchaseOrders_Stage]
ALTER COLUMN [OrderedQty] INT NULL;
GO

USE [Charcoal_Inventory_Analytics];
GO

SELECT TOP (5) *
FROM [dbo].[FactPurchaseOrders_Stage];

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'FactPurchaseOrders_Stage'
  AND COLUMN_NAME IN (
      'OrderedQty',
      'UnitPurchaseCostPKR'
  );

USE [Charcoal_Inventory_Analytics];
GO

ALTER TABLE [dbo].[FactPurchaseOrders_Stage]
ALTER COLUMN [UnitPurchaseCostPKR] DECIMAL(18,2) NULL;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FactPurchaseOrders_Stage'
  AND COLUMN_NAME = 'UnitPurchaseCostPKR';

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT POLineID) AS UniquePOLineIDs,
    COUNT(*) - COUNT(DISTINCT POLineID) AS DuplicateOrNullDifference,
    SUM(CASE WHEN POLineID IS NULL THEN 1 ELSE 0 END)
        AS NullPOLineIDs
FROM dbo.FactPurchaseOrders_Stage;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalRecords,

    SUM(CASE WHEN POID IS NULL THEN 1 ELSE 0 END)
        AS MissingPOID,

    SUM(CASE WHEN SupplierID IS NULL THEN 1 ELSE 0 END)
        AS MissingSupplierID,

    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END)
        AS MissingProductID,

    SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END)
        AS MissingOrderDate,

    SUM(CASE WHEN PromisedDate IS NULL THEN 1 ELSE 0 END)
        AS MissingPromisedDate,

    SUM(CASE WHEN DestinationWarehouseID IS NULL THEN 1 ELSE 0 END)
        AS MissingWarehouseID,

    SUM(CASE WHEN OrderedQty IS NULL THEN 1 ELSE 0 END)
        AS MissingOrderedQty,

    SUM(CASE WHEN UnitPurchaseCostPKR IS NULL THEN 1 ELSE 0 END)
        AS MissingPurchaseCost

FROM dbo.FactPurchaseOrders_Stage;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalRecords,

    SUM(CASE
        WHEN OrderedQty <= 0 THEN 1 ELSE 0
    END) AS InvalidOrderedQty,

    SUM(CASE
        WHEN UnitPurchaseCostPKR <= 0 THEN 1 ELSE 0
    END) AS InvalidPurchaseCost,

    SUM(CASE
        WHEN PromisedDate < OrderDate THEN 1 ELSE 0
    END) AS InvalidPromisedDate

FROM dbo.FactPurchaseOrders_Stage;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalRecords,

    SUM(CASE
        WHEN NULLIF(TRIM(POLineID), '') IS NULL
        THEN 1 ELSE 0
    END) AS BlankPOLineID,

    SUM(CASE
        WHEN NULLIF(TRIM(POID), '') IS NULL
        THEN 1 ELSE 0
    END) AS BlankPOID,

    SUM(CASE
        WHEN NULLIF(TRIM(SupplierID), '') IS NULL
        THEN 1 ELSE 0
    END) AS BlankSupplierID,

    SUM(CASE
        WHEN NULLIF(TRIM(ProductID), '') IS NULL
        THEN 1 ELSE 0
    END) AS BlankProductID,

    SUM(CASE
        WHEN NULLIF(TRIM(DestinationWarehouseID), '') IS NULL
        THEN 1 ELSE 0
    END) AS BlankWarehouseID

FROM dbo.FactPurchaseOrders_Stage;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    POID,
    ProductID,
    COUNT(*) AS RecordCount
FROM dbo.FactPurchaseOrders_Stage
GROUP BY
    POID,
    ProductID
HAVING COUNT(*) > 1
ORDER BY RecordCount DESC;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND (
      TABLE_NAME LIKE '%Supplier%'
      OR TABLE_NAME LIKE '%Product%'
      OR TABLE_NAME LIKE '%Warehouse%'
  )
ORDER BY TABLE_NAME;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalSuppliers,
    COUNT(DISTINCT SupplierID) AS UniqueSuppliers
FROM dbo.DimSuppliers_Stage;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalProducts,
    COUNT(DISTINCT ProductID) AS UniqueProducts,
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END)
        AS NullProductIDs
FROM dbo.DimProductVariants_Stage;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalWarehouses,
    COUNT(DISTINCT WarehouseID) AS UniqueWarehouses,

    SUM(
        CASE
            WHEN WarehouseID IS NULL
              OR LTRIM(RTRIM(WarehouseID)) = ''
            THEN 1
            ELSE 0
        END
    ) AS MissingWarehouseIDs

FROM dbo.DimWarehouses_Stage;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalPurchaseOrders,

    SUM(CASE
        WHEN S.SupplierID IS NULL THEN 1
        ELSE 0
    END) AS MissingSuppliers,

    SUM(CASE
        WHEN P.ProductID IS NULL THEN 1
        ELSE 0
    END) AS MissingProducts,

    SUM(CASE
        WHEN W.WarehouseID IS NULL THEN 1
        ELSE 0
    END) AS MissingWarehouses

FROM dbo.FactPurchaseOrders_Stage AS PO

LEFT JOIN dbo.DimSuppliers_Stage AS S
    ON PO.SupplierID = S.SupplierID

LEFT JOIN dbo.DimProductVariants_Stage AS P
    ON PO.ProductID = P.ProductID

LEFT JOIN dbo.DimWarehouses_Stage AS W
    ON PO.DestinationWarehouseID = W.WarehouseID;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalGoodsReceipts,
    COUNT(DISTINCT ReceiptLineID) AS UniqueReceiptLineIDs,
    COUNT(DISTINCT POLineID) AS PurchaseOrderLinesCovered,
    SUM(CASE
        WHEN ReceiptLineID IS NULL THEN 1
        ELSE 0
    END) AS NullReceiptLineIDs
FROM dbo.FactGoodsReceipts_Stage;


USE [Charcoal_Inventory_Analytics];
GO

WITH ReceiptSummary AS (
    SELECT
        POLineID,
        SUM(ReceivedQty) AS TotalReceivedQty
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
)

SELECT
    PO.POLineID,
    PO.POID,
    PO.SupplierID,
    PO.ProductID,
    PO.OrderedQty,

    COALESCE(R.TotalReceivedQty, 0) AS TotalReceivedQty,

    PO.OrderedQty - COALESCE(R.TotalReceivedQty, 0)
        AS OutstandingQty,

    CASE
        WHEN R.POLineID IS NULL THEN 'Not Received'
        WHEN PO.OrderedQty = R.TotalReceivedQty THEN 'Fully Received'
        WHEN PO.OrderedQty > R.TotalReceivedQty THEN 'Partially Received'
        ELSE 'Over Received'
    END AS ReceiptStatus

FROM dbo.FactPurchaseOrders_Stage AS PO

LEFT JOIN ReceiptSummary AS R
    ON PO.POLineID = R.POLineID

ORDER BY PO.POLineID;

---------------

USE [Charcoal_Inventory_Analytics];
GO

WITH LastReceipt AS (
    SELECT
        POLineID,
        MAX(ReceiptDate) AS LastReceiptDate
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
)

SELECT
    PO.POLineID,
    PO.POID,
    PO.SupplierID,
    PO.OrderDate,
    PO.PromisedDate,
    R.LastReceiptDate,

    DATEDIFF(
        DAY,
        PO.PromisedDate,
        R.LastReceiptDate
    ) AS DeliveryDelayDays,

    CASE
        WHEN R.LastReceiptDate IS NULL
            THEN 'Not Received'

        WHEN R.LastReceiptDate <= PO.PromisedDate
            THEN 'On Time'

        ELSE 'Late'
    END AS DeliveryStatus

FROM dbo.FactPurchaseOrders_Stage AS PO

LEFT JOIN LastReceipt AS R
    ON PO.POLineID = R.POLineID

ORDER BY PO.POLineID;

------------

USE [Charcoal_Inventory_Analytics];
GO

WITH LastReceipt AS (
    SELECT
        POLineID,
        MAX(ReceiptDate) AS LastReceiptDate
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
),

DeliveryPerformance AS (
    SELECT
        PO.POLineID,
        PO.PromisedDate,
        R.LastReceiptDate,

        DATEDIFF(
            DAY,
            PO.PromisedDate,
            R.LastReceiptDate
        ) AS DeliveryDelayDays

    FROM dbo.FactPurchaseOrders_Stage AS PO

    LEFT JOIN LastReceipt AS R
        ON PO.POLineID = R.POLineID
)

SELECT
    COUNT(*) AS TotalPOLines,

    SUM(CASE
        WHEN LastReceiptDate <= PromisedDate
        THEN 1 ELSE 0
    END) AS OnTimeDeliveries,

    SUM(CASE
        WHEN LastReceiptDate > PromisedDate
        THEN 1 ELSE 0
    END) AS LateDeliveries,

    SUM(CASE
        WHEN LastReceiptDate IS NULL
        THEN 1 ELSE 0
    END) AS NotReceived,

    CAST(
        100.0 * SUM(CASE
            WHEN LastReceiptDate <= PromisedDate
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS OnTimeDeliveryPct,

    CAST(
        AVG(CASE
            WHEN DeliveryDelayDays > 0
            THEN CAST(DeliveryDelayDays AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AvgLateDeliveryDays

FROM DeliveryPerformance;

-------------

USE [Charcoal_Inventory_Analytics];
GO

WITH LastReceipt AS (
    SELECT
        POLineID,
        MAX(ReceiptDate) AS LastReceiptDate
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
),
SupplierDelivery AS (
    SELECT
        PO.SupplierID,
        PO.POLineID,
        DATEDIFF(
            DAY,
            PO.PromisedDate,
            R.LastReceiptDate
        ) AS DelayDays
    FROM dbo.FactPurchaseOrders_Stage AS PO
    LEFT JOIN LastReceipt AS R
        ON PO.POLineID = R.POLineID
)
SELECT
    SupplierID,
    COUNT(*) AS TotalPOLines,

    SUM(CASE
        WHEN DelayDays <= 0 THEN 1 ELSE 0
    END) AS OnTimeDeliveries,

    SUM(CASE
        WHEN DelayDays > 0 THEN 1 ELSE 0
    END) AS LateDeliveries,

    CAST(
        100.0 * SUM(CASE
            WHEN DelayDays <= 0 THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS OnTimeDeliveryPct,

    CAST(
        AVG(CASE
            WHEN DelayDays > 0
            THEN CAST(DelayDays AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AvgLateDeliveryDays

FROM SupplierDelivery
GROUP BY SupplierID
ORDER BY OnTimeDeliveryPct ASC, LateDeliveries DESC;

-------------
USE [Charcoal_Inventory_Analytics];
GO

WITH LastReceipt AS (
    SELECT
        POLineID,
        MAX(ReceiptDate) AS LastReceiptDate
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
),
SupplierPerformance AS (
    SELECT
        PO.SupplierID,
        COUNT(*) AS TotalPOLines,

        SUM(CASE
            WHEN R.LastReceiptDate <= PO.PromisedDate
            THEN 1 ELSE 0
        END) AS OnTimeDeliveries,

        SUM(CASE
            WHEN R.LastReceiptDate > PO.PromisedDate
            THEN 1 ELSE 0
        END) AS LateDeliveries

    FROM dbo.FactPurchaseOrders_Stage AS PO
    LEFT JOIN LastReceipt AS R
        ON PO.POLineID = R.POLineID
    GROUP BY PO.SupplierID
)
SELECT TOP (1)
    SupplierID,
    TotalPOLines,
    OnTimeDeliveries,
    LateDeliveries,

    CAST(
        100.0 * OnTimeDeliveries
        / NULLIF(TotalPOLines, 0)
        AS DECIMAL(5,2)
    ) AS OnTimeDeliveryPct

FROM SupplierPerformance
ORDER BY
    OnTimeDeliveryPct ASC,
    TotalPOLines DESC;

    ----------------------

USE [Charcoal_Inventory_Analytics];
GO

WITH LastReceipt AS (
    SELECT
        POLineID,
        MAX(ReceiptDate) AS LastReceiptDate
    FROM dbo.FactGoodsReceipts_Stage
    GROUP BY POLineID
),
SupplierDelays AS (
    SELECT
        PO.SupplierID,
        PO.POLineID,
        DATEDIFF(
            DAY,
            PO.PromisedDate,
            R.LastReceiptDate
        ) AS DelayDays
    FROM dbo.FactPurchaseOrders_Stage AS PO
    LEFT JOIN LastReceipt AS R
        ON PO.POLineID = R.POLineID
)
SELECT
    SupplierID,

    COUNT(*) AS TotalPOLines,

    SUM(CASE
        WHEN DelayDays > 0 THEN 1 ELSE 0
    END) AS LateDeliveries,

    CAST(
        AVG(CASE
            WHEN DelayDays > 0
            THEN CAST(DelayDays AS DECIMAL(10,2))
        END)
        AS DECIMAL(10,2)
    ) AS AvgDelayDays,

    MAX(CASE
        WHEN DelayDays > 0 THEN DelayDays
    END) AS MaximumDelayDays

FROM SupplierDelays
WHERE SupplierID = 'SUP011'
GROUP BY SupplierID;

-----------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalSalesRecords,
    COUNT(DISTINCT SalesLineID) AS UniqueSalesLineIDs,
    SUM(UnitsSold) AS TotalUnitsSold,
    SUM(
        UnitsSold * UnitSellingPricePKR
        - DiscountPKR
    ) AS TotalNetSalesPKR
FROM dbo.FactSales_Stage;

-------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalMovements,
    COUNT(DISTINCT MovementID) AS UniqueMovementIDs,
    SUM(CASE WHEN SignedQty < 0 THEN 1 ELSE 0 END)
        AS NegativeMovements,
    SUM(CASE WHEN SignedQty > 0 THEN 1 ELSE 0 END)
        AS PositiveMovements,
    SUM(CASE WHEN SignedQty = 0 THEN 1 ELSE 0 END)
        AS ZeroMovements
FROM dbo.FactStockMovements_Stage;

------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    MovementType,
    COUNT(*) AS TotalMovements,

    SUM(CASE
        WHEN SignedQty > 0 THEN 1 ELSE 0
    END) AS PositiveMovements,

    SUM(CASE
        WHEN SignedQty < 0 THEN 1 ELSE 0
    END) AS NegativeMovements,

    SUM(SignedQty) AS NetQuantityMovement

FROM dbo.FactStockMovements_Stage

GROUP BY MovementType

ORDER BY TotalMovements DESC;

-----

USE [Charcoal_Inventory_Analytics];
GO

WITH SalesSummary AS (
    SELECT
        COUNT(*) AS SalesRecords,
        SUM(UnitsSold) AS TotalUnitsSold
    FROM dbo.FactSales_Stage
),
MovementSummary AS (
    SELECT
        COUNT(*) AS SaleMovements,
        SUM(SignedQty) AS InventorySalesQty
    FROM dbo.FactStockMovements_Stage
    WHERE MovementType = 'Sale'
)
SELECT
    S.SalesRecords,
    M.SaleMovements,
    S.TotalUnitsSold,
    M.InventorySalesQty,

    S.TotalUnitsSold + M.InventorySalesQty
        AS ReconciliationDifference,

    CASE
        WHEN S.TotalUnitsSold + M.InventorySalesQty = 0
         AND S.SalesRecords = M.SaleMovements
        THEN 'PASS'
        ELSE 'FAIL'
    END AS ValidationStatus

FROM SalesSummary AS S
CROSS JOIN MovementSummary AS M;

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalTransfers
FROM dbo.FactTransfers_Stage;

-----

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'FactTransfers_Stage'
ORDER BY ORDINAL_POSITION;

USE [Charcoal_Inventory_Analytics];
GO

SELECT TOP (10)
    TransferID,
    FromWarehouseID,
    ToStoreID,
    ProductID,
    TransferQty
FROM dbo.FactTransfers_Stage;

----

USE [Charcoal_Inventory_Analytics];
GO

SELECT TOP (10)
    TransferID,
    FromWarehouseID,
    ToStoreID,
    ProductID,
    TransferQty
FROM dbo.FactTransfers_Stage
ORDER BY TransferID;

SELECT
    COUNT(*) AS TotalTransfers,
    COUNT(DISTINCT TransferID) AS UniqueTransfers,
    SUM(CASE
        WHEN ToStoreID IS NULL
          OR LTRIM(RTRIM(ToStoreID)) = ''
        THEN 1 ELSE 0
    END) AS MissingStoreIDs
FROM dbo.FactTransfers_Stage_Fixed;

select * from dbo.FactTransfers_Stage_Fixed;

----------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalTransfers,

    COUNT(DISTINCT TransferID) AS UniqueTransferIDs,

    SUM(CASE
        WHEN TransferQty IS NULL OR TransferQty <= 0
        THEN 1 ELSE 0
    END) AS InvalidTransferQty,

    SUM(CASE
        WHEN ToStoreID IS NULL
          OR ToStoreID NOT LIKE 'S[0-9][0-9][0-9]'
        THEN 1 ELSE 0
    END) AS InvalidStoreIDs

FROM dbo.FactTransfers_Stage;

--------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalReturnRecords,

    COUNT(DISTINCT ReturnLineID)
        AS UniqueReturnLineIDs,

    SUM(ReturnedQty)
        AS TotalReturnedUnits,

    SUM(RestockableQty)
        AS TotalRestockableUnits,

    SUM(CASE
        WHEN ReturnedQty IS NULL
          OR ReturnedQty <= 0
          OR RestockableQty IS NULL
          OR RestockableQty < 0
          OR RestockableQty > ReturnedQty
        THEN 1 ELSE 0
    END) AS InvalidReturnRecords

FROM dbo.FactReturns_Stage;

---------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalInventoryRecords
FROM dbo.FactInventory_Stage;

---------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'FactInventory_Stage'
ORDER BY ORDINAL_POSITION;

---

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalSnapshots,

    COUNT(DISTINCT SnapshotID) AS UniqueSnapshots,

    SUM(CASE
        WHEN RecordedClosingQty < 0
          OR CalculatedClosingQty < 0
        THEN 1 ELSE 0
    END) AS NegativeStockRecords,

    SUM(CASE
        WHEN RecordedClosingQty <> CalculatedClosingQty
        THEN 1 ELSE 0
    END) AS MismatchRecords,

    SUM(CASE
        WHEN RecordedClosingQty - CalculatedClosingQty
             <> DiscrepancyQty
        THEN 1 ELSE 0
    END) AS IncorrectDiscrepancyCalculations

FROM dbo.FactInventory_Stage;

---- Charcoal ke kin products aur locations par inventory differences exist karte hain, 
---  aur difference kitni units ka hai?

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    SnapshotID,
    SnapshotDate,
    ProductID,
    LocationID,
    RecordedClosingQty,
    CalculatedClosingQty,
    DiscrepancyQty,

    CASE
        WHEN DiscrepancyQty < 0
            THEN 'Stock Shortage'
        WHEN DiscrepancyQty > 0
            THEN 'Stock Surplus'
        ELSE 'Matched'
    END AS DiscrepancyStatus

FROM dbo.FactInventory_Stage

WHERE RecordedClosingQty <> CalculatedClosingQty

ORDER BY
    ABS(DiscrepancyQty) DESC;


--------- Charcoal ki total sales performance kya hai? -------------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    COUNT(*) AS TotalSalesLines,

    COUNT(DISTINCT SaleID) AS TotalSalesOrders,

    SUM(UnitsSold) AS TotalUnitsSold,

    SUM(
        UnitsSold * UnitSellingPricePKR
    ) AS GrossSalesPKR,

    SUM(DiscountPKR) AS TotalDiscountPKR,

    SUM(
        UnitsSold * UnitSellingPricePKR - DiscountPKR
    ) AS NetSalesPKR,

    CAST(
        SUM(
            UnitsSold * UnitSellingPricePKR - DiscountPKR
        ) * 1.0 / NULLIF(COUNT(DISTINCT SaleID), 0)
        AS DECIMAL(18,2)
    ) AS AverageOrderValuePKR

FROM dbo.FactSales_Stage;

------ Charcoal ki monthly sales increase ho rahi hain ya decrease? Kaunse months mein sales performance weak rahi?

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    DATEFROMPARTS(
        YEAR(SaleDate),
        MONTH(SaleDate),
        1
    ) AS SalesMonth,

    COUNT(DISTINCT SaleID) AS TotalOrders,

    SUM(UnitsSold) AS TotalUnitsSold,

    SUM(
        UnitsSold * UnitSellingPricePKR
        - DiscountPKR
    ) AS NetSalesPKR

FROM dbo.FactSales_Stage

GROUP BY
    DATEFROMPARTS(
        YEAR(SaleDate),
        MONTH(SaleDate),
        1
    )

ORDER BY SalesMonth;

--- Kya Charcoal ki sales pichle month ke comparison mein increase hui hain ya decrease?


USE [Charcoal_Inventory_Analytics];
GO

WITH MonthlySales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(SaleDate),
            MONTH(SaleDate),
            1
        ) AS SalesMonth,

        SUM(
            UnitsSold * UnitSellingPricePKR
            - DiscountPKR
        ) AS NetSalesPKR

    FROM dbo.FactSales_Stage

    GROUP BY
        DATEFROMPARTS(
            YEAR(SaleDate),
            MONTH(SaleDate),
            1
        )
),

SalesWithPreviousMonth AS (
    SELECT
        SalesMonth,
        NetSalesPKR,

        LAG(NetSalesPKR) OVER (
            ORDER BY SalesMonth
        ) AS PreviousMonthSalesPKR

    FROM MonthlySales
)

SELECT 
    SalesMonth,
    NetSalesPKR,
    PreviousMonthSalesPKR,

    CAST(
        100.0 *
        (NetSalesPKR - PreviousMonthSalesPKR)
        / NULLIF(PreviousMonthSalesPKR, 0)
        AS DECIMAL(10,2)
    ) AS MoMGrowthPct,

    CASE
        WHEN PreviousMonthSalesPKR IS NULL
            THEN 'First Month'
        WHEN NetSalesPKR > PreviousMonthSalesPKR
            THEN 'Growth'
        WHEN NetSalesPKR < PreviousMonthSalesPKR
            THEN 'Decline'
        ELSE 'No Change'
    END AS SalesTrend

FROM SalesWithPreviousMonth

ORDER BY SalesMonth ;

--- Top 10 Products by Net Sales

USE [Charcoal_Inventory_Analytics];
GO

SELECT TOP (10)
    ProductID,

    COUNT(*) AS SalesLines,

    SUM(UnitsSold) AS TotalUnitsSold,

    CAST(
        SUM(
            UnitsSold * UnitSellingPricePKR
            - DiscountPKR
        ) AS DECIMAL(18,2)
    ) AS NetSalesPKR

FROM dbo.FactSales_Stage

GROUP BY ProductID

ORDER BY NetSalesPKR DESC;

----- Charcoal ke 10 stores mein se kaunsa store sabse zyada revenue generate kar raha hai 
---   aur kaunsa comparatively weak perform kar raha hai?

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    StoreID,

    COUNT(DISTINCT SaleID) AS TotalOrders,

    SUM(UnitsSold) AS TotalUnitsSold,

    CAST(
        SUM(
            UnitsSold * UnitSellingPricePKR
            - DiscountPKR
        ) AS DECIMAL(18,2)
    ) AS NetSalesPKR,

    CAST(
        SUM(
            UnitsSold * UnitSellingPricePKR
            - DiscountPKR
        ) * 100.0
        / NULLIF(
            SUM(SUM(
                UnitsSold * UnitSellingPricePKR
                - DiscountPKR
            )) OVER (), 0
        )
        AS DECIMAL(5,2)
    ) AS RevenueContributionPct

FROM dbo.FactSales_Stage

GROUP BY StoreID

ORDER BY NetSalesPKR DESC;

-- Kya Charcoal ke inventory movements ka combined stock balance logically reconcile ho raha hai?

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    SUM(CASE
        WHEN MovementType = 'Opening'
        THEN SignedQty ELSE 0
    END) AS OpeningStock,

    SUM(CASE
        WHEN MovementType = 'Receipt'
        THEN SignedQty ELSE 0
    END) AS ReceivedStock,

    SUM(CASE
        WHEN MovementType = 'Sale'
        THEN SignedQty ELSE 0
    END) AS SalesMovement,

    SUM(CASE
        WHEN MovementType IN ('Transfer In', 'Transfer Out')
        THEN SignedQty ELSE 0
    END) AS NetTransfers,

    SUM(CASE
        WHEN MovementType = 'Return Restock'
        THEN SignedQty ELSE 0
    END) AS ReturnRestock,

    SUM(SignedQty) AS CalculatedTotalStock

FROM dbo.FactStockMovements_Sta


----------------


USE [Charcoal_Inventory_Analytics];
GO

-- CHECK 1: REFERENTIAL INTEGRITY

SELECT
    'Sales → Stores' AS Validation,
    COUNT(*) AS TotalRecords,
    SUM(CASE
        WHEN D.StoreID IS NULL THEN 1
        ELSE 0
    END) AS MissingReferences
FROM dbo.FactSales_Stage AS F
LEFT JOIN dbo.DimStores_Stage AS D
    ON F.StoreID = D.StoreID

UNION ALL

SELECT
    'Sales → Products',
    COUNT(*),
    SUM(CASE
        WHEN D.ProductID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactSales_Stage AS F
LEFT JOIN dbo.DimProductVariants_Stage AS D
    ON F.ProductID = D.ProductID

UNION ALL

SELECT
    'Returns → Sales',
    COUNT(*),
    SUM(CASE
        WHEN S.SalesLineID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactReturns_Stage AS R
LEFT JOIN dbo.FactSales_Stage AS S
    ON R.SalesLineID = S.SalesLineID

UNION ALL

SELECT
    'Transfers → Stores',
    COUNT(*),
    SUM(CASE
        WHEN D.StoreID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactTransfers_Stage AS T
LEFT JOIN dbo.DimStores_Stage AS D
    ON T.ToStoreID = D.StoreID

UNION ALL

SELECT
    'Transfers → Warehouses',
    COUNT(*),
    SUM(CASE
        WHEN D.WarehouseID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactTransfers_Stage AS T
LEFT JOIN dbo.DimWarehouses_Stage AS D
    ON T.FromWarehouseID = D.WarehouseID

UNION ALL

SELECT
    'Transfers → Products',
    COUNT(*),
    SUM(CASE
        WHEN D.ProductID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactTransfers_Stage AS T
LEFT JOIN dbo.DimProductVariants_Stage AS D
    ON T.ProductID = D.ProductID

UNION ALL

SELECT
    'Inventory → Products',
    COUNT(*),
    SUM(CASE
        WHEN D.ProductID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactInventory_Stage AS I
LEFT JOIN dbo.DimProductVariants_Stage AS D
    ON I.ProductID = D.ProductID

UNION ALL

SELECT
    'Movements → Products',
    COUNT(*),
    SUM(CASE
        WHEN D.ProductID IS NULL THEN 1
        ELSE 0
    END)
FROM dbo.FactStockMovements_Stage AS M
LEFT JOIN dbo.DimProductVariants_Stage AS D
    ON M.ProductID = D.ProductID;

-------

USE [Charcoal_Inventory_Analytics];
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'FactTransfers_Stage',
      'DimStores_Stage',
      'DimWarehouses_Stage',
      'FactSales_Stage',
      'DimProductVariants_Stage'
  )
  AND COLUMN_NAME IN (
      'StoreID',
      'ToStoreID',
      'FromWarehouseID',
      'WarehouseID',
      'ProductID'
  )
ORDER BY TABLE_NAME, COLUMN_NAME;


USE [Charcoal_Inventory_Analytics];
GO

SELECT
    StoreID,
    StoreName
FROM dbo.DimStores_Stage
ORDER BY StoreID;


-------------- check 2


USE [Charcoal_Inventory_Analytics];
GO

WITH TransferMovements AS (
    SELECT
        SourceDocumentID,

        SUM(CASE
            WHEN MovementType = 'Transfer Out'
            THEN SignedQty ELSE 0
        END) AS OutQty,

        SUM(CASE
            WHEN MovementType = 'Transfer In'
            THEN SignedQty ELSE 0
        END) AS InQty,

        SUM(CASE
            WHEN MovementType = 'Transfer Out'
            THEN 1 ELSE 0
        END) AS OutRecords,

        SUM(CASE
            WHEN MovementType = 'Transfer In'
            THEN 1 ELSE 0
        END) AS InRecords

    FROM dbo.FactStockMovements_Stage
    WHERE MovementType IN (
        'Transfer Out', 'Transfer In'
    )
    GROUP BY SourceDocumentID
)

SELECT
    COUNT(*) AS TotalTransfers,

    SUM(CASE
        WHEN M.SourceDocumentID IS NULL
        THEN 1 ELSE 0
    END) AS MissingMovementPairs,

    SUM(CASE
        WHEN M.SourceDocumentID IS NOT NULL
         AND (
             M.OutQty <> -T.TransferQty
             OR M.InQty <> T.TransferQty
         )
        THEN 1 ELSE 0
    END) AS QuantityMismatches,

    SUM(CASE
        WHEN M.SourceDocumentID IS NOT NULL
         AND (
             M.OutRecords <> 1
             OR M.InRecords <> 1
         )
        THEN 1 ELSE 0
    END) AS MovementCountMismatches

FROM dbo.FactTransfers_Stage T

LEFT JOIN TransferMovements M
    ON T.TransferID = M.SourceDocumentID;

--- Check 3 — Goods Receipts Reconciliation


USE [Charcoal_Inventory_Analytics];
GO

WITH ReceiptMovements AS (
    SELECT
        SourceDocumentID,
        COUNT(*) AS MovementCount,
        SUM(SignedQty) AS MovementQty
    FROM dbo.FactStockMovements_Stage
    WHERE MovementType = 'Receipt'
    GROUP BY SourceDocumentID
)

SELECT
    COUNT(*) AS TotalReceiptLines,

    SUM(CASE
        WHEN M.SourceDocumentID IS NULL
        THEN 1 ELSE 0
    END) AS MissingReceiptMovements,

    SUM(CASE
        WHEN M.SourceDocumentID IS NOT NULL
         AND M.MovementQty <> R.AcceptedQty
        THEN 1 ELSE 0
    END) AS QuantityMismatches,

    SUM(CASE
        WHEN M.SourceDocumentID IS NOT NULL
         AND M.MovementCount <> 1
        THEN 1 ELSE 0
    END) AS MovementCountMismatches,

    SUM(R.ReceivedQty) AS TotalReceivedUnits,
    SUM(R.AcceptedQty) AS TotalAcceptedUnits,
    SUM(R.RejectedQty) AS TotalRejectedUnits

FROM dbo.FactGoodsReceipts_Stage AS R

LEFT JOIN ReceiptMovements AS M
    ON R.ReceiptLineID = M.SourceDocumentID;
