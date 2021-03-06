USE [DB_A452AF_chabagan]
GO
/****** Object:  UserDefinedFunction [dbo].[MyHTMLDecode]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MyHTMLDecode] (@vcWhat nVARCHAR(MAX))
RETURNS nVARCHAR(MAX)
AS
BEGIN
    DECLARE @vcResult nVARCHAR(MAX)
    DECLARE @siPos INT
        ,@vcEncoded nVARCHAR(7)
        ,@siChar INT

    SET @vcResult = RTRIM(LTRIM(CAST(REPLACE(@vcWhat COLLATE Latin1_General_BIN, CHAR(0), '') AS nVARCHAR(MAX))))

    SELECT @vcResult = REPLACE(REPLACE(@vcResult, '&#160;', ' '), '&nbsp;', ' ')

    IF @vcResult = ''
        RETURN @vcResult

    SELECT @siPos = PATINDEX('%&#[0-9][0-9][0-9];%', @vcResult)

    WHILE @siPos > 0
    BEGIN
        SELECT @vcEncoded = SUBSTRING(@vcResult, @siPos, 6)
            ,@siChar = CAST(SUBSTRING(@vcEncoded, 3, 3) AS INT)
            ,@vcResult = REPLACE(@vcResult, @vcEncoded, NCHAR(@siChar))
            ,@siPos = PATINDEX('%&#[0-9][0-9][0-9];%', @vcResult)
    END

    SELECT @siPos = PATINDEX('%&#[0-9][0-9][0-9][0-9];%', @vcResult)

    WHILE @siPos > 0
    BEGIN
        SELECT @vcEncoded = SUBSTRING(@vcResult, @siPos, 7)
            ,@siChar = CAST(SUBSTRING(@vcEncoded, 3, 4) AS INT)
            ,@vcResult = REPLACE(@vcResult, @vcEncoded, NCHAR(@siChar))
            ,@siPos = PATINDEX('%&#[0-9][0-9][0-9][0-9];%', @vcResult)
    END

    SELECT @siPos = PATINDEX('%#[0-9][0-9][0-9][0-9]%', @vcResult)

    WHILE @siPos > 0
    BEGIN
        SELECT @vcEncoded = SUBSTRING(@vcResult, @siPos, 5)
            ,@vcResult = REPLACE(@vcResult, @vcEncoded, '')
            ,@siPos = PATINDEX('%#[0-9][0-9][0-9][0-9]%', @vcResult)
    END

    SELECT @vcResult = REPLACE(REPLACE(@vcResult, NCHAR(160), ' '), CHAR(160), ' ')

    SELECT @vcResult = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@vcResult, '&amp;', '&'), '&quot;', '"'), '&lt;', '<'), '&gt;', '>'), '&amp;amp;', '&')

    RETURN @vcResult
END





GO
/****** Object:  UserDefinedFunction [dbo].[udf_StripHTML]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_StripHTML] (@HTMLText nVARCHAR(MAX))
RETURNS nVARCHAR(MAX) AS
BEGIN
    DECLARE @Start INT
    DECLARE @End INT
    DECLARE @Length INT
    SET @Start = CHARINDEX('<',@HTMLText)
    SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
    SET @Length = (@End - @Start) + 1
    WHILE @Start > 0 AND @End > 0 AND @Length > 0
    BEGIN
        SET @HTMLText = STUFF(@HTMLText,@Start,@Length,'')
        SET @Start = CHARINDEX('<',@HTMLText)
        SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
        SET @Length = (@End - @Start) + 1
    END
    RETURN LTRIM(RTRIM(@HTMLText))
END





GO
/****** Object:  UserDefinedFunction [dbo].[uf_AddThousandSeparators]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_AddThousandSeparators](@NumStr nvarchar(50))
RETURNS nVarchar(50)
AS
BEGIN
declare @OutStr nVarchar(50)
declare @i int
declare @run int

Select @i=CHARINDEX('.',@NumStr)
if @i=0 
    begin
    set @i=LEN(@NumStr)
    Set @Outstr=''
    end
else
    begin   
     Set @Outstr=SUBSTRING(@NUmStr,@i,50)
     Set @i=@i -1
    end 


Set @run=0

While @i>0
    begin
      if @Run=3
        begin
          Set @Outstr=','+@Outstr
          Set @run=0
        end
      Set @Outstr=SUBSTRING(@NumStr,@i,1) +@Outstr  
      Set @i=@i-1
      Set @run=@run + 1     
    end

    RETURN @OutStr

END





GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetAreaNameByAreaId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetAreaNameByAreaId] 
(
	@areaId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)
   
   SELECT @Result = [Name] from [dbo].[Area] where [ID] = @areaId;
      
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetAreaNamesWithCommaByPurchaseId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uf_GetAreaNamesWithCommaByPurchaseId]
(
	@rowId as int
)
RETURNS  nvarchar(MAX)
AS
BEGIN





 DECLARE @returnValue  nvarchar(MAX);
	SELECT  @returnValue= COALESCE(@returnValue + ', ', '') +  ar.Name   FROM FeedSellingReportMapper mp
				INNER JOIN [dbo].[Area] ar on ar.[Id]=mp.[MapperAreaId]
                WHERE 
                    mp.FeedSellingReportId=@rowId



	RETURN @returnValue;

END

GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFeedCategorynameByFeedCategoryId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFeedCategorynameByFeedCategoryId] 
(
	@id int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [FeedCategoryName] from [dbo].[FeedCategories] where [FeedCategoryId] = @id;
   
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFeedNameByFeedId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFeedNameByFeedId] 
(
	@feedId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [Name] from [dbo].[Feed] where [ID] = @feedId;

   IF @Result IS NULL or @Result = '' SET @Result = 'Not Found'

   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFeedNamesWithCommaByPurchaseId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uf_GetFeedNamesWithCommaByPurchaseId]
(
	@rowId as int
)
RETURNS  nvarchar(MAX)
AS
BEGIN





 DECLARE @returnValue  nvarchar(MAX);
	SELECT  @returnValue= COALESCE(@returnValue + ', ', '') +  t.Name + ' (' + ct.[FeedCategoryName] +')'  FROM FeedSellingReportMapper mp
                INNER JOIN Feed t ON mp.FeedId = t.ID
				INNER JOIN [dbo].[FeedCategories] ct on ct.[FeedCategoryId]=mp.[FeedCategoryId]
                WHERE 
                    mp.FeedSellingReportId=@rowId



	---- Declare the return variable here
	
	--SET @returnValue = '';
	--Declare @Id int;
	--DECLARE @nameTableTemp TABLE(ID INT,Name nvarchar(50))
	--Declare @totalRow  int;
 --   Declare @incrementCounter  int;
	--SET @incrementCounter = 1
	
	--INSERT INTO @nameTableTemp
	--SELECT t.ID, t.Name + ' (' + ct.[FeedCategoryName] +')'  FROM FeedSellingReportMapper mp
 --               INNER JOIN Feed t ON mp.FeedId = t.ID
	--			INNER JOIN [dbo].[FeedCategories] ct on ct.[FeedCategoryId]=mp.[FeedCategoryId]
 --               WHERE 
 --                   mp.FeedSellingReportId=@rowId;



 -- SELECT @totalRow = Count(*) From @nameTableTemp;

	-- While (Select Count(*) From @nameTableTemp) > 0
	--	Begin

	--		Select Top 1 @Id = ID From @nameTableTemp

	--		Select Top 1 @returnValue = @returnValue + Name From @nameTableTemp

	--		SET @incrementCounter = @incrementCounter + 1;

	--		IF(@incrementCounter <= @totalRow) 
	--		BEGIN
	--		  SET @returnValue = @returnValue +', '
	--		END

	--		--Do some processing here

	--		Delete @nameTableTemp Where @Id = ID

	--	End

	-- Return the result of the function
	RETURN @returnValue;

END

GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFeedNameWithCategoryByFeedIdAndCatId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFeedNameWithCategoryByFeedIdAndCatId] 
(
	@feedId int,
	@catId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)
   DECLARE @feedName AS nvarchar(max)
   DECLARE @categoryName AS nvarchar(max)

   SELECT @feedName = [Name] from [dbo].[Feed] where [ID] = @feedId;
   IF @feedName IS NULL or @feedName = '' SET @feedName = 'Not Found'

   SELECT @categoryName = [FeedCategoryName] from [dbo].[FeedCategories] where [FeedCategoryId] = @catId;
   IF @categoryName IS NULL or @categoryName = '' SET @categoryName = 'Not Found'

   SET @Result = @feedName + ' ('+ @categoryName + ')'

   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishNameByFishId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishNameByFishId] 
(
	@fishId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [Name] from [dbo].[Fish] where [ID] = @fishId;
   
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId]
(
	@rowId as int
)
RETURNS  nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnValue  nvarchar(MAX);
	SET @returnValue = '';
	Declare @Id int;
	DECLARE @nameTableTemp TABLE(ID INT,Name nvarchar(50))
	Declare @totalRow  int;
    Declare @incrementCounter  int;
	SET @incrementCounter = 1
	
	INSERT INTO @nameTableTemp
	SELECT t.ID, t.Name FROM FishSellingReportMapper mp
                INNER JOIN Fish t
                 ON
                    mp.SellFishId = t.ID
                WHERE 
                    mp.FishSellReportId=@rowId;



  SELECT @totalRow = Count(*) From @nameTableTemp;

	 While (Select Count(*) From @nameTableTemp) > 0
		Begin

			Select Top 1 @Id = ID From @nameTableTemp

			Select Top 1 @returnValue = @returnValue + Name From @nameTableTemp

			SET @incrementCounter = @incrementCounter + 1;

			IF(@incrementCounter <= @totalRow) 
			BEGIN
			  SET @returnValue = @returnValue +', '
			END

			--Do some processing here

			Delete @nameTableTemp Where @Id = ID

		End

	-- Return the result of the function
	RETURN @returnValue;

END

GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerDueAmount]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerDueAmount] 
(
	@projectid int,
	@SellDate as datetime,
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.FishAmountDue)  from FishSellingReport c where projectid=@projectid and SellDate=@SellDate and FishSellerId=@FishSellerId;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerDueAmountBySellerId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerDueAmountBySellerId] 
(
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.FishAmountDue)  from FishSellingReport c where FishSellerId=@FishSellerId AND IsClosedByAdmin=0;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerNameByFishId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[uf_GetFishSellerNameByFishId] 
(
	@fishSellerId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [Name] from [dbo].[FishSeller] where [ID] = @fishSellerId;
   
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerNameByFishShellerId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[uf_GetFishSellerNameByFishShellerId] 
(
	@fishSellerId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [Name] from [dbo].[FishSeller] where [ID] = @fishSellerId;
   
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerPaidAmount]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerPaidAmount] 
(
	@projectid int,
	@SellDate as datetime,
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.FishAmountPaid)  from FishSellingReport c where projectid=@projectid and SellDate=@SellDate and FishSellerId=@FishSellerId;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerPaidAmountBySellerId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerPaidAmountBySellerId] 
(
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.FishAmountPaid)  from FishSellingReport c where FishSellerId=@FishSellerId AND IsClosedByAdmin=0;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerTotalAmount]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerTotalAmount] 
(
	@projectid int,
	@SellDate as datetime,
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.TotalSellPrice)  from FishSellingReport c where projectid=@projectid and SellDate=@SellDate and FishSellerId=@FishSellerId;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetFishSellerTotalAmountBySellerId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetFishSellerTotalAmountBySellerId] 
(
	@FishSellerId as int
	
)
RETURNS Decimal(18,2)
AS
BEGIN  
   DECLARE @Result AS Decimal(18,2);
   SELECT @Result = sum (c.TotalSellPrice)  from FishSellingReport c where  FishSellerId=@FishSellerId AND IsClosedByAdmin=0;
   
   IF @Result IS NULL SET @Result = 0
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetProjectNameByProjectId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetProjectNameByProjectId] 
(
	@id int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)

   SELECT @Result = [Name] from [dbo].[Project] where [ID] = @id;
   
   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  UserDefinedFunction [dbo].[uf_GetUserProjectNameByAreaIdAndProjectId]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[uf_GetUserProjectNameByAreaIdAndProjectId] 
(
	@areaId int,
	@projectId int
	
)
RETURNS nvarchar(max)
AS
BEGIN  
   DECLARE @Result AS nvarchar(max)
   DECLARE @areaName AS nvarchar(max)  
   DECLARE @projectName AS nvarchar(max)
   
   SELECT @areaName = [Name] from [dbo].[Area] where [ID] = @areaId;
   SELECT @projectName = [Name] from [dbo].[Project] where [ID] = @projectId;
      

	  IF @areaName IS not null and @projectName is not null
		SET @Result = @areaName + ' (' + @projectName + ')'

	IF @areaName IS null and @projectName is not null
		SET @Result =  @projectName

	IF @areaName IS not null and @projectName is null
		SET @Result = @areaName 

   IF @Result IS NULL SET @Result = 'Not Found'
      
   RETURN @Result
END




GO
/****** Object:  Table [dbo].[Area]    Script Date: 7/14/2019 12:53:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Area](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Union_Name] [nvarchar](500) NULL,
	[WardNumber] [nvarchar](500) NULL,
	[ImageUrl] [nvarchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedId] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Expend]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Expend](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedId] [int] NOT NULL,
 CONSTRAINT [PK_Expend] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ExpendReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpendReport](
	[ExpendReportId] [int] IDENTITY(1,1) NOT NULL,
	[ExpendRepoterName] [nvarchar](max) NOT NULL,
	[ExpendId] [int] NOT NULL,
	[TotalExpend] [decimal](18, 2) NOT NULL,
	[CreateDate] [date] NOT NULL,
	[CreatedId] [int] NOT NULL,
	[ExpandNote] [nvarchar](max) NULL,
 CONSTRAINT [PK_ExpendReport] PRIMARY KEY CLUSTERED 
(
	[ExpendReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ExpendReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpendReportMapper](
	[ExpendMapperId] [int] IDENTITY(1,1) NOT NULL,
	[ExpendReportId] [int] NOT NULL,
	[AreaId] [int] NOT NULL,
	[ExpendAmount] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_ExpendReportMapper] PRIMARY KEY CLUSTERED 
(
	[ExpendMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FarmRentalReports]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FarmRentalReports](
	[FarmRentalReportID] [int] IDENTITY(1,1) NOT NULL,
	[FarmRentalReportName] [nvarchar](max) NOT NULL,
	[FarmRentalDetails] [nvarchar](max) NOT NULL,
	[FarmRentalLandAmount] [decimal](18, 2) NOT NULL,
	[FarmRentalServieFee] [decimal](18, 2) NOT NULL,
	[FarmRentalMainFee] [decimal](18, 2) NOT NULL,
	[FarmRentalTotalFee] [decimal](18, 2) NOT NULL,
	[FarmRentalCostPerAmount] [decimal](18, 2) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedDate] [date] NULL,
	[CreatedID] [int] NULL,
	[EditedDate] [date] NULL,
	[EditedID] [int] NULL,
	[FarmRentalDate] [date] NOT NULL,
	[ProjectId] [int] NOT NULL,
	[AreaId] [int] NOT NULL,
 CONSTRAINT [PK_FarmRentalReports] PRIMARY KEY CLUSTERED 
(
	[FarmRentalReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Feed]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feed](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedId] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Feed] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedCategories]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedCategories](
	[FeedCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[FeedCategoryName] [nvarchar](max) NOT NULL,
	[FeedCategoryDetails] [nvarchar](max) NOT NULL,
	[FeedCategoryImageUrl] [nvarchar](max) NOT NULL,
	[CreatedDate] [date] NULL,
	[CreatedId] [int] NULL,
	[FeedCategoryFeedId] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FeedCategories] PRIMARY KEY CLUSTERED 
(
	[FeedCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedDistributionFeedIdReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedDistributionFeedIdReportMapper](
	[FeedDistributionFeedIdReportMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FeedDistributionReportId] [int] NOT NULL,
	[FeedDistributionFeedId] [int] NOT NULL,
 CONSTRAINT [PK_FeedDistributionFeedIdReportMapper] PRIMARY KEY CLUSTERED 
(
	[FeedDistributionFeedIdReportMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedDistributionReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedDistributionReport](
	[FeedDistributionReportId] [int] IDENTITY(1,1) NOT NULL,
	[FeedDistributionName] [nvarchar](max) NOT NULL,
	[FeedDistributionDate] [date] NOT NULL,
	[FeedDistributionTotalWeight] [decimal](18, 2) NOT NULL,
	[CreatedId] [int] NULL,
	[CreatedDate] [date] NULL,
	[EditedId] [int] NULL,
	[EditedDate] [date] NULL,
	[FeedDistributionDescription] [nvarchar](max) NULL,
	[AreaId] [int] NULL,
	[ProjectId] [int] NULL,
 CONSTRAINT [PK_FeedDistributionReports_1] PRIMARY KEY CLUSTERED 
(
	[FeedDistributionReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedDistributionReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedDistributionReportMapper](
	[FeedDistributionReportMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FeedDistributionFeedIdReportMapperId] [int] NOT NULL,
	[FeedDistributionFeedategoryId] [int] NOT NULL,
	[FeedDistributionQuantityId] [decimal](18, 2) NOT NULL,
	[FeedDistributionSakNumber] [decimal](18, 2) NOT NULL,
	[FeedDistributionTotalWeight] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_FeedDistributionReportMapper] PRIMARY KEY CLUSTERED 
(
	[FeedDistributionReportMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedDistributionReports]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedDistributionReports](
	[FeedDistributionReportId] [int] IDENTITY(1,1) NOT NULL,
	[FeedDistributionName] [nvarchar](max) NOT NULL,
	[FeedDistributionDate] [date] NOT NULL,
	[FeedDistributionFeedId] [int] NOT NULL,
	[FeedDistributionFeedategoryId] [int] NOT NULL,
	[FeedDistributionQuantityId] [decimal](18, 2) NOT NULL,
	[FeedDistributionSakNumber] [decimal](18, 2) NOT NULL,
	[FeedDistributionTotalWeight] [decimal](18, 2) NOT NULL,
	[CreatedId] [int] NULL,
	[CreatedDate] [date] NULL,
	[EditedId] [int] NULL,
	[EditedDate] [date] NULL,
	[FeedDistributionDescription] [nvarchar](max) NULL,
	[AreaId] [int] NOT NULL,
	[ProjectId] [int] NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_FeedDistributionReports] PRIMARY KEY CLUSTERED 
(
	[FeedDistributionReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedPurchaseDueReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedPurchaseDueReportMapper](
	[FeedPurchaseDueReportMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FeedPurchaseId] [int] NOT NULL,
	[FeedPurchaseAmountDue] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_FeedPurchaseDueReportMapper] PRIMARY KEY CLUSTERED 
(
	[FeedPurchaseDueReportMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedSellingReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedSellingReport](
	[FeedSellingReportId] [int] IDENTITY(1,1) NOT NULL,
	[SellingFeedReportNumber] [nvarchar](max) NOT NULL,
	[SellingReportName] [nvarchar](max) NOT NULL,
	[SellingFeedTotalWeight] [decimal](18, 0) NOT NULL,
	[SellingFeedTotalPrice] [decimal](18, 0) NOT NULL,
	[SellingFeedCalculationDate] [date] NOT NULL,
	[SellingFeedCreateDate] [date] NULL,
	[SellingFeedCreatedId] [int] NULL,
	[SellingFeedEditedDate] [date] NULL,
	[SellignFeedEditedId] [int] NULL,
	[SellingFeedSellNote] [nvarchar](max) NULL,
	[IsClosedByAdmin] [int] NOT NULL,
	[FeedAmountPaid] [decimal](18, 2) NULL,
	[FeedAmountDue] [decimal](18, 2) NULL,
	[AreaId] [int] NOT NULL,
	[ProjectId] [int] NOT NULL,
 CONSTRAINT [PK_FeedSellingReport] PRIMARY KEY CLUSTERED 
(
	[FeedSellingReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedSellingReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedSellingReportMapper](
	[FeedSellingReportMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FeedSellingReportId] [int] NOT NULL,
	[FeedId] [int] NOT NULL,
	[FeedCategoryId] [int] NOT NULL,
	[FeedTotalBags] [int] NOT NULL,
	[FeedBagsWeight] [int] NOT NULL,
	[TotalWeight] [decimal](18, 2) NOT NULL,
	[PricePerKg] [decimal](18, 2) NOT NULL,
	[TotalPrice] [decimal](18, 2) NOT NULL,
	[MapperAreaId] [int] NOT NULL,
 CONSTRAINT [PK_FeedSellingReportMapper] PRIMARY KEY CLUSTERED 
(
	[FeedSellingReportMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Fish]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fish](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedId] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Fish] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FishAmountDueReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishAmountDueReportMapper](
	[FishSellerReportMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FishSellerId] [int] NOT NULL,
	[FishSellReportId] [int] NOT NULL,
	[FishAmountDue] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_FishAmountDueReportMapper] PRIMARY KEY CLUSTERED 
(
	[FishSellerReportMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FishBillingHistory]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishBillingHistory](
	[FishBillingId] [int] IDENTITY(1,1) NOT NULL,
	[FishBillingFishSellId] [int] NOT NULL,
	[FishBillingFishInKG] [decimal](18, 2) NOT NULL,
	[FishBillingTotalPrice] [decimal](18, 2) NOT NULL,
	[FishBillingPaidAmount] [decimal](18, 2) NOT NULL,
	[FishBillingDueAmount] [decimal](18, 2) NOT NULL,
	[FishBillingUserId] [int] NOT NULL,
	[FishBillingDate] [datetime] NOT NULL,
	[BillingType] [nvarchar](1) NOT NULL,
 CONSTRAINT [PK_FishBillingHistory] PRIMARY KEY CLUSTERED 
(
	[FishBillingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FishSeller]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishSeller](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Age] [int] NOT NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedId] [int] NULL,
	[Description] [nvarchar](max) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FishSeller] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FishSellingReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishSellingReport](
	[FishSellId] [int] IDENTITY(1,1) NOT NULL,
	[TotalSellInKG] [decimal](18, 2) NOT NULL,
	[HisabName] [nvarchar](250) NULL,
	[GarirName] [nvarchar](250) NULL,
	[SellDate] [date] NOT NULL,
	[TotalSellPrice] [decimal](18, 2) NOT NULL,
	[CalculatedDate] [date] NULL,
	[CalculatedById] [int] NULL,
	[CalculationEditedDate] [date] NULL,
	[CalCulationEditedId] [int] NULL,
	[SellNote] [nvarchar](max) NULL,
	[AreaId] [int] NOT NULL,
	[ProjectId] [int] NOT NULL,
	[FishSellerId] [int] NOT NULL,
	[FishAmountPaid] [decimal](18, 2) NOT NULL,
	[FishAmountDue] [decimal](18, 2) NOT NULL,
	[IsClosedByAdmin] [int] NOT NULL,
 CONSTRAINT [PK_FishSellingReport] PRIMARY KEY CLUSTERED 
(
	[FishSellId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FishSellingReportMapper]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishSellingReportMapper](
	[FishSellMapperId] [int] IDENTITY(1,1) NOT NULL,
	[FishSellReportId] [int] NOT NULL,
	[FishSellerId] [int] NOT NULL,
	[SellFishId] [int] NOT NULL,
	[TotalFishkg] [decimal](18, 2) NOT NULL,
	[PiecesPerKG] [int] NOT NULL,
	[TotalPiecesFish] [int] NOT NULL,
	[PricePerKG] [decimal](18, 2) NOT NULL,
	[TotalSellPrice] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_FishSellingReportMapper] PRIMARY KEY CLUSTERED 
(
	[FishSellMapperId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Project]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Project](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[AreaId] [int] NOT NULL,
	[Land] [nvarchar](max) NULL,
	[Cost] [nvarchar](max) NULL,
	[Time] [nvarchar](max) NULL,
	[ImageUrl] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedId] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [bigint] IDENTITY(1,1) NOT NULL,
	[AddressOne] [nvarchar](200) NULL,
	[AddressTwo] [nvarchar](200) NULL,
	[City] [nvarchar](100) NULL,
	[ConfirmPassword] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[CreatedBy] [bigint] NULL,
	[CreatedDate] [datetime] NULL,
	[CurrentPassword] [nvarchar](max) NULL,
	[AreaID] [int] NULL,
	[EditedBy] [bigint] NULL,
	[EditedDate] [datetime] NULL,
	[EmailAddress] [nvarchar](200) NULL,
	[FirstName] [nvarchar](100) NULL,
	[IsActivated] [bit] NOT NULL,
	[IsTemporaryPassword] [bit] NULL,
	[LastName] [nvarchar](100) NULL,
	[Password] [nvarchar](100) NOT NULL,
	[ProjectID] [int] NOT NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[Position] [nvarchar](100) NULL,
	[PostCode] [nvarchar](50) NULL,
	[PublicationStatus] [bit] NULL,
	[Religion] [nvarchar](100) NULL,
	[RegistrationConfirmed] [nvarchar](50) NULL,
	[Role] [nvarchar](200) NULL,
	[UserImageCaption] [nvarchar](max) NULL,
	[UserImagePath] [nvarchar](max) NULL,
	[UserImageSize] [bigint] NULL,
	[UserName] [nvarchar](50) NULL,
	[UserRegistartionGuid] [nvarchar](max) NULL,
	[IsTrialUser] [bit] NULL,
	[TrialStartDate] [datetime] NULL,
	[TrialEndDate] [datetime] NULL,
	[IsImageUploadedByUser] [bit] NOT NULL,
	[UserCreatedBy] [nvarchar](200) NOT NULL,
	[CreatedIP] [nvarchar](500) NULL,
	[EditedIP] [nvarchar](500) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Area] ON 

INSERT [dbo].[Area] ([ID], [Name], [Union_Name], [WardNumber], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (7, N'বেগমপুর', N'বেগম পুর', N'১', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:00:57.027' AS DateTime), 1, 0)
INSERT [dbo].[Area] ([ID], [Name], [Union_Name], [WardNumber], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (8, N'সরকার', N'সরকার', N'২', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:01:20.917' AS DateTime), 1, 0)
INSERT [dbo].[Area] ([ID], [Name], [Union_Name], [WardNumber], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (9, N'খইলশাজানি', N'খইশাজানি', N'৩', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:01:38.247' AS DateTime), 1, 0)
INSERT [dbo].[Area] ([ID], [Name], [Union_Name], [WardNumber], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (10, N'শেকেরবাইদ', N'বয়ালী', N'চাবাগান', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17 08:07:23.017' AS DateTime), 1, 0)
INSERT [dbo].[Area] ([ID], [Name], [Union_Name], [WardNumber], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (11, N'শাহাবাড়ী', N'ফুল বাড়িয়া', N'বঙ্গবাজার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17 08:09:35.317' AS DateTime), 1, 0)
SET IDENTITY_INSERT [dbo].[Area] OFF
SET IDENTITY_INSERT [dbo].[Expend] ON 

INSERT [dbo].[Expend] ([ID], [IsDeleted], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId]) VALUES (1, 0, N'update ', N'update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;update&amp;nbsp;', N'Uploads/CostReport/8790ecc6-b5da-412b-893f-fa55f02c02cb-shahrukh-khan-kajol_142381006640.jpg', CAST(N'2019-04-24 10:48:32.990' AS DateTime), 1)
INSERT [dbo].[Expend] ([ID], [IsDeleted], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId]) VALUES (2, 0, N'sgfsdfg  sdfgsdfg', N' sfg sfdg sdfg sdfg', N'Uploads/CreateSegment/Area/520d82e3-a7a5-46b3-8526-6ab6ad846a9a-8c3e8423deba6b41172c74e73c5aba6e.jpg', CAST(N'2019-04-24 10:54:03.637' AS DateTime), 1)
INSERT [dbo].[Expend] ([ID], [IsDeleted], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId]) VALUES (3, 1, N'dhdfg dg h', N'dghdgh', N'Uploads/CostReport60e29ebd-5916-4b60-b81d-84e5696dc44a-53625553_1264319677067637_1351185308183429120_n.jpg', CAST(N'2019-04-24 11:07:03.480' AS DateTime), 1)
INSERT [dbo].[Expend] ([ID], [IsDeleted], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId]) VALUES (4, 0, N'sfgsfd', N'gsfgsdf sfdg', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-24 11:08:00.773' AS DateTime), 1)
INSERT [dbo].[Expend] ([ID], [IsDeleted], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId]) VALUES (5, 1, N'sfgsfdg', N'sfdgsfdsfg', N'Uploads/CostReportfd86d34b-7ee0-4194-8fe7-c52076ab0604-shahrukh-khan-kajol_142381006640.jpg', CAST(N'2019-04-24 11:09:03.453' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Expend] OFF
SET IDENTITY_INSERT [dbo].[ExpendReport] ON 

INSERT [dbo].[ExpendReport] ([ExpendReportId], [ExpendRepoterName], [ExpendId], [TotalExpend], [CreateDate], [CreatedId], [ExpandNote]) VALUES (1, N'TEst', 1, CAST(30.00 AS Decimal(18, 2)), CAST(N'2019-05-19' AS Date), 3, N'This is a test.')
SET IDENTITY_INSERT [dbo].[ExpendReport] OFF
SET IDENTITY_INSERT [dbo].[ExpendReportMapper] ON 

INSERT [dbo].[ExpendReportMapper] ([ExpendMapperId], [ExpendReportId], [AreaId], [ExpendAmount]) VALUES (8, 1, 9, CAST(20.00 AS Decimal(18, 2)))
INSERT [dbo].[ExpendReportMapper] ([ExpendMapperId], [ExpendReportId], [AreaId], [ExpendAmount]) VALUES (9, 1, 10, CAST(10.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[ExpendReportMapper] OFF
SET IDENTITY_INSERT [dbo].[FarmRentalReports] ON 

INSERT [dbo].[FarmRentalReports] ([FarmRentalReportID], [FarmRentalReportName], [FarmRentalDetails], [FarmRentalLandAmount], [FarmRentalServieFee], [FarmRentalMainFee], [FarmRentalTotalFee], [FarmRentalCostPerAmount], [IsDeleted], [CreatedDate], [CreatedID], [EditedDate], [EditedID], [FarmRentalDate], [ProjectId], [AreaId]) VALUES (1, N'', N'sfdgsdfg sf sfd sfd sfg sfdg', CAST(25.00 AS Decimal(18, 2)), CAST(32.00 AS Decimal(18, 2)), CAST(42.00 AS Decimal(18, 2)), CAST(74.00 AS Decimal(18, 2)), CAST(2.96 AS Decimal(18, 2)), 0, CAST(N'2019-03-21' AS Date), 3, CAST(N'2019-03-21' AS Date), 3, CAST(N'2019-03-06' AS Date), 21, 8)
INSERT [dbo].[FarmRentalReports] ([FarmRentalReportID], [FarmRentalReportName], [FarmRentalDetails], [FarmRentalLandAmount], [FarmRentalServieFee], [FarmRentalMainFee], [FarmRentalTotalFee], [FarmRentalCostPerAmount], [IsDeleted], [CreatedDate], [CreatedID], [EditedDate], [EditedID], [FarmRentalDate], [ProjectId], [AreaId]) VALUES (4, N'', N'', CAST(45.00 AS Decimal(18, 2)), CAST(5454.00 AS Decimal(18, 2)), CAST(454545.00 AS Decimal(18, 2)), CAST(459999.00 AS Decimal(18, 2)), CAST(10222.20 AS Decimal(18, 2)), 0, CAST(N'2019-03-21' AS Date), 3, NULL, NULL, CAST(N'2019-03-21' AS Date), 11, 7)
SET IDENTITY_INSERT [dbo].[FarmRentalReports] OFF
SET IDENTITY_INSERT [dbo].[Feed] ON 

INSERT [dbo].[Feed] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (12, N'কে এন বি', N'কে এন বি কোম্পানি', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:48:33.520' AS DateTime), 1, 0)
INSERT [dbo].[Feed] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (13, N'কাজী', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:48:54.333' AS DateTime), 1, 0)
INSERT [dbo].[Feed] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (14, N'মেগা', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:49:04.637' AS DateTime), 1, 0)
INSERT [dbo].[Feed] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (15, N'ফিসটেক', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17 09:24:52.373' AS DateTime), 1, 0)
SET IDENTITY_INSERT [dbo].[Feed] OFF
SET IDENTITY_INSERT [dbo].[FeedCategories] ON 

INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (16, N'ফিনিশার', N'কে এন বি ফিনিশার&amp;nbsp;', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (17, N'গ্রোয়ার', N'কে এন বি গ্রোয়ার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (18, N'প্রি স্টাটার', N'কে এন বি স্টাটার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (19, N'স্টাটার', N'কে এন বি স্টাটার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (20, N'নার্সারি', N'কে এন বি নার্সারি', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (21, N'ফিনিশার', N'কাজী ফিনিশার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (22, N'গ্রোয়ার', N'কাজি গ্রোয়ার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (23, N'স্টাটার', N'কাজি স্টাটার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (24, N'প্রি স্টাটার', N'কাজি প্রি স্টাটার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (25, N'পাওডার', N'কাজি পাওডার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (26, N'কারপ গ্রোয়ার', N'কারপ গ্রোয়ার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (27, N'কার্প গ্রোয়ার', N'কারপ গ্রোয়ার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-20' AS Date), 1, 12, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (28, N'কার্প গ্রোয়ার', N'কার্প গ্রোয়ার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-20' AS Date), 1, 13, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (29, N'০.৫ মিলি ', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17' AS Date), 1, 15, 0)
INSERT [dbo].[FeedCategories] ([FeedCategoryId], [FeedCategoryName], [FeedCategoryDetails], [FeedCategoryImageUrl], [CreatedDate], [CreatedId], [FeedCategoryFeedId], [IsDeleted]) VALUES (30, N'নার্সারি ১', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-05-01' AS Date), 1, 12, 0)
SET IDENTITY_INSERT [dbo].[FeedCategories] OFF
SET IDENTITY_INSERT [dbo].[FeedDistributionReports] ON 

INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (14, N'খাদ্য', CAST(N'2019-03-16' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)), CAST(50.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-11' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (15, N'খাদ্য', CAST(N'2019-03-17' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(100.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-11' AS Date), 12, CAST(N'2019-04-11' AS Date), NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (16, N'খাদ্য', CAST(N'2019-03-18' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(125.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-11' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (18, N'খাদ্য', CAST(N'2019-03-19' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(125.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (19, N'খাদ্য', CAST(N'2019-03-20' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(125.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (20, N'খাদ্য', CAST(N'2019-03-21' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(150.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (21, N'খাদ্য', CAST(N'2019-03-22' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(150.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (22, N'খাদ্য', CAST(N'2019-03-23' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(150.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (23, N'খাদ্য', CAST(N'2019-03-24' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(150.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (24, N'খাদ্য', CAST(N'2019-03-25' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(125.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (25, N'খাদ্য', CAST(N'2019-03-26' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(125.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (26, N'খাদ্য', CAST(N'2019-03-26' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(1.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (27, N'খাদ্য', CAST(N'2019-03-27' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(100.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (28, N'খাদ্য', CAST(N'2019-02-27' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(1.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (29, N'খাদ্য', CAST(N'2019-03-28' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(100.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (30, N'খাদ্য', CAST(N'2019-03-28' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)), CAST(20.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (31, N'খাদ্য', CAST(N'2019-03-29' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(100.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (32, N'খাদ্য', CAST(N'2019-03-29' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(40.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (33, N'খাদ্য', CAST(N'2019-03-30' AS Date), 12, 27, CAST(25.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(100.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (34, N'খাদ্য', CAST(N'2019-03-30' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)), CAST(30.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), 12, CAST(N'2019-04-16' AS Date), NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (35, N'খাদ্য', CAST(N'2019-03-31' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(2.00 AS Decimal(18, 2)), CAST(20.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-16' AS Date), NULL, NULL, NULL, 8, 27, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (36, N'খাদ্য', CAST(N'2019-04-17' AS Date), 12, 20, CAST(10.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)), CAST(30.00 AS Decimal(18, 2)), 12, CAST(N'2019-04-17' AS Date), 12, CAST(N'2019-04-17' AS Date), NULL, 7, 13, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (37, N'খাদ্য', CAST(N'2019-05-01' AS Date), 12, 20, CAST(20.00 AS Decimal(18, 2)), CAST(1.00 AS Decimal(18, 2)), CAST(20.00 AS Decimal(18, 2)), 12, CAST(N'2019-05-01' AS Date), NULL, NULL, NULL, 7, 13, 1)
INSERT [dbo].[FeedDistributionReports] ([FeedDistributionReportId], [FeedDistributionName], [FeedDistributionDate], [FeedDistributionFeedId], [FeedDistributionFeedategoryId], [FeedDistributionQuantityId], [FeedDistributionSakNumber], [FeedDistributionTotalWeight], [CreatedId], [CreatedDate], [EditedId], [EditedDate], [FeedDistributionDescription], [AreaId], [ProjectId], [IsActive]) VALUES (38, N'খাদ্য', CAST(N'2019-05-01' AS Date), 12, 30, CAST(20.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(120.00 AS Decimal(18, 2)), 12, CAST(N'2019-05-01' AS Date), NULL, NULL, NULL, 7, 13, 1)
SET IDENTITY_INSERT [dbo].[FeedDistributionReports] OFF
SET IDENTITY_INSERT [dbo].[FeedPurchaseDueReportMapper] ON 

INSERT [dbo].[FeedPurchaseDueReportMapper] ([FeedPurchaseDueReportMapperId], [FeedPurchaseId], [FeedPurchaseAmountDue]) VALUES (23, 13, CAST(513000.00 AS Decimal(18, 2)))
INSERT [dbo].[FeedPurchaseDueReportMapper] ([FeedPurchaseDueReportMapperId], [FeedPurchaseId], [FeedPurchaseAmountDue]) VALUES (27, 17, CAST(564000.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[FeedPurchaseDueReportMapper] OFF
SET IDENTITY_INSERT [dbo].[FeedSellingReport] ON 

INSERT [dbo].[FeedSellingReport] ([FeedSellingReportId], [SellingFeedReportNumber], [SellingReportName], [SellingFeedTotalWeight], [SellingFeedTotalPrice], [SellingFeedCalculationDate], [SellingFeedCreateDate], [SellingFeedCreatedId], [SellingFeedEditedDate], [SellignFeedEditedId], [SellingFeedSellNote], [IsClosedByAdmin], [FeedAmountPaid], [FeedAmountDue], [AreaId], [ProjectId]) VALUES (13, N'2084047', N'খাদ্য ক্রয়', CAST(13000 AS Decimal(18, 0)), CAST(513000 AS Decimal(18, 0)), CAST(N'2019-03-30' AS Date), CAST(N'2019-04-04' AS Date), 12, NULL, NULL, NULL, 0, CAST(0.00 AS Decimal(18, 2)), CAST(513000.00 AS Decimal(18, 2)), 0, 0)
INSERT [dbo].[FeedSellingReport] ([FeedSellingReportId], [SellingFeedReportNumber], [SellingReportName], [SellingFeedTotalWeight], [SellingFeedTotalPrice], [SellingFeedCalculationDate], [SellingFeedCreateDate], [SellingFeedCreatedId], [SellingFeedEditedDate], [SellignFeedEditedId], [SellingFeedSellNote], [IsClosedByAdmin], [FeedAmountPaid], [FeedAmountDue], [AreaId], [ProjectId]) VALUES (17, N'2084047', N'kazi', CAST(12000 AS Decimal(18, 0)), CAST(564000 AS Decimal(18, 0)), CAST(N'2019-04-09' AS Date), CAST(N'2019-04-09' AS Date), 12, NULL, NULL, NULL, 0, CAST(0.00 AS Decimal(18, 2)), CAST(564000.00 AS Decimal(18, 2)), 0, 0)
SET IDENTITY_INSERT [dbo].[FeedSellingReport] OFF
SET IDENTITY_INSERT [dbo].[FeedSellingReportMapper] ON 

INSERT [dbo].[FeedSellingReportMapper] ([FeedSellingReportMapperId], [FeedSellingReportId], [FeedId], [FeedCategoryId], [FeedTotalBags], [FeedBagsWeight], [TotalWeight], [PricePerKg], [TotalPrice], [MapperAreaId]) VALUES (57, 13, 13, 21, 240, 25, CAST(6000.00 AS Decimal(18, 2)), CAST(47.00 AS Decimal(18, 2)), CAST(282000.00 AS Decimal(18, 2)), 7)
INSERT [dbo].[FeedSellingReportMapper] ([FeedSellingReportMapperId], [FeedSellingReportId], [FeedId], [FeedCategoryId], [FeedTotalBags], [FeedBagsWeight], [TotalWeight], [PricePerKg], [TotalPrice], [MapperAreaId]) VALUES (58, 13, 13, 26, 280, 25, CAST(7000.00 AS Decimal(18, 2)), CAST(33.00 AS Decimal(18, 2)), CAST(231000.00 AS Decimal(18, 2)), 8)
INSERT [dbo].[FeedSellingReportMapper] ([FeedSellingReportMapperId], [FeedSellingReportId], [FeedId], [FeedCategoryId], [FeedTotalBags], [FeedBagsWeight], [TotalWeight], [PricePerKg], [TotalPrice], [MapperAreaId]) VALUES (63, 17, 13, 21, 480, 25, CAST(12000.00 AS Decimal(18, 2)), CAST(47.00 AS Decimal(18, 2)), CAST(564000.00 AS Decimal(18, 2)), 7)
SET IDENTITY_INSERT [dbo].[FeedSellingReportMapper] OFF
SET IDENTITY_INSERT [dbo].[Fish] ON 

INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (10, N'তেলাপিয়া', N'নতুন জাতের মাছ যুক্ত করুন', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 06:55:38.517' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (12, N'পাবদা', N'্দাচদ্ভ', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 06:59:44.760' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (13, N'গুলশা ', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:00:59.183' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (14, N'রুই', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:45:26.950' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (15, N'কাতল', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:45:37.910' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (16, N'কারপু', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:45:47.367' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (17, N'বাংলা', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:46:40.707' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (18, N'মিশালী', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 07:46:54.790' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (19, N'সিলভার', N'সিল্ভার', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-11 08:39:17.450' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (20, N'ব্রিগেড', N'ব্রিগেড', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-11 08:39:45.490' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (21, N'পুটি', N'পুটি', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-11 08:40:03.487' AS DateTime), 1, 0)
INSERT [dbo].[Fish] ([ID], [Name], [Description], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (22, N'ছোট তেলাপিয়া', NULL, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-21 08:58:26.513' AS DateTime), 1, 0)
SET IDENTITY_INSERT [dbo].[Fish] OFF
SET IDENTITY_INSERT [dbo].[FishAmountDueReportMapper] ON 

INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (18, 9, 18, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (27, 9, 27, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (28, 9, 28, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (29, 9, 29, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (30, 9, 30, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (31, 9, 31, CAST(0.00 AS Decimal(18, 2)))
INSERT [dbo].[FishAmountDueReportMapper] ([FishSellerReportMapperId], [FishSellerId], [FishSellReportId], [FishAmountDue]) VALUES (32, 9, 32, CAST(0.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[FishAmountDueReportMapper] OFF
SET IDENTITY_INSERT [dbo].[FishBillingHistory] ON 

INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (44, 18, CAST(1525.50 AS Decimal(18, 2)), CAST(225885.00 AS Decimal(18, 2)), CAST(1.00 AS Decimal(18, 2)), CAST(225884.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 08:31:15.113' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (45, 19, CAST(1525.50 AS Decimal(18, 2)), CAST(224700.00 AS Decimal(18, 2)), CAST(1.00 AS Decimal(18, 2)), CAST(224699.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 08:34:08.640' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (46, 18, CAST(1525.50 AS Decimal(18, 2)), CAST(225885.00 AS Decimal(18, 2)), CAST(100000.00 AS Decimal(18, 2)), CAST(125884.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 08:37:49.573' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (47, 18, CAST(1525.50 AS Decimal(18, 2)), CAST(225885.00 AS Decimal(18, 2)), CAST(125884.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 08:41:11.867' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (48, 19, CAST(1525.50 AS Decimal(18, 2)), CAST(224700.00 AS Decimal(18, 2)), CAST(24116.00 AS Decimal(18, 2)), CAST(200583.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 08:41:11.867' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (49, 20, CAST(45.00 AS Decimal(18, 2)), CAST(2025.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-10 11:20:51.707' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (50, 21, CAST(1232.50 AS Decimal(18, 2)), CAST(189542.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-11 08:45:21.770' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (51, 22, CAST(840.50 AS Decimal(18, 2)), CAST(127787.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-11 08:51:54.427' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (52, 23, CAST(87.00 AS Decimal(18, 2)), CAST(11745.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(11745.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-14 13:32:09.327' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (53, 24, CAST(98.00 AS Decimal(18, 2)), CAST(12250.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(12250.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-17 11:04:59.287' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (54, 25, CAST(450.00 AS Decimal(18, 2)), CAST(66150.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(66150.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-18 08:26:12.160' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (55, 26, CAST(460.00 AS Decimal(18, 2)), CAST(67620.00 AS Decimal(18, 2)), CAST(67620.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-18 08:36:51.977' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (56, 27, CAST(600.00 AS Decimal(18, 2)), CAST(89400.00 AS Decimal(18, 2)), CAST(894400.00 AS Decimal(18, 2)), CAST(89400.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-21 08:54:20.680' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (57, 28, CAST(1514.50 AS Decimal(18, 2)), CAST(230862.50 AS Decimal(18, 2)), CAST(230862.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-21 09:07:43.873' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (58, 29, CAST(1238.00 AS Decimal(18, 2)), CAST(207456.50 AS Decimal(18, 2)), CAST(207456.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-21 09:16:53.337' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (59, 30, CAST(2842.00 AS Decimal(18, 2)), CAST(442116.50 AS Decimal(18, 2)), CAST(442116.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-23 07:05:17.273' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (60, 27, CAST(600.00 AS Decimal(18, 2)), CAST(89400.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-24 10:04:48.067' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (61, 28, CAST(1514.50 AS Decimal(18, 2)), CAST(230862.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-24 10:04:50.557' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (62, 29, CAST(1238.00 AS Decimal(18, 2)), CAST(207456.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-24 10:04:52.967' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (63, 30, CAST(2842.00 AS Decimal(18, 2)), CAST(442116.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-03-24 10:04:55.393' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (64, 31, CAST(814.00 AS Decimal(18, 2)), CAST(130440.00 AS Decimal(18, 2)), CAST(100000.00 AS Decimal(18, 2)), CAST(30440.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-29 07:14:40.507' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (65, 31, CAST(814.00 AS Decimal(18, 2)), CAST(130440.00 AS Decimal(18, 2)), CAST(30440.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 12, CAST(N'2019-03-29 07:18:02.157' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (66, 32, CAST(721.00 AS Decimal(18, 2)), CAST(58730.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(58730.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-03 10:12:44.147' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (67, 33, CAST(40.00 AS Decimal(18, 2)), CAST(400.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(400.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-07 22:39:01.640' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (68, 34, CAST(10.00 AS Decimal(18, 2)), CAST(1000.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(1000.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-07 22:42:06.047' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (69, 35, CAST(963.00 AS Decimal(18, 2)), CAST(107763.00 AS Decimal(18, 2)), CAST(10658.00 AS Decimal(18, 2)), CAST(97105.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 00:16:38.890' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (70, 35, CAST(963.00 AS Decimal(18, 2)), CAST(107763.00 AS Decimal(18, 2)), CAST(10663.00 AS Decimal(18, 2)), CAST(97100.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 00:26:26.587' AS DateTime), N'T')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (71, 36, CAST(10.00 AS Decimal(18, 2)), CAST(10010.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(10010.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 00:49:15.057' AS DateTime), N'I')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (72, 36, CAST(10.00 AS Decimal(18, 2)), CAST(10010.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 00:52:20.900' AS DateTime), N'B')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (73, 36, CAST(10.00 AS Decimal(18, 2)), CAST(10010.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 01:02:42.273' AS DateTime), N'U')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (74, 37, CAST(10.00 AS Decimal(18, 2)), CAST(1010.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(1010.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-08 01:07:09.077' AS DateTime), N'I')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (75, 38, CAST(30.00 AS Decimal(18, 2)), CAST(300.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(300.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-07 12:15:10.443' AS DateTime), N'U')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (76, 39, CAST(10.00 AS Decimal(18, 2)), CAST(10100.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(10100.00 AS Decimal(18, 2)), 3, CAST(N'2019-04-11 01:56:48.423' AS DateTime), N'I')
INSERT [dbo].[FishBillingHistory] ([FishBillingId], [FishBillingFishSellId], [FishBillingFishInKG], [FishBillingTotalPrice], [FishBillingPaidAmount], [FishBillingDueAmount], [FishBillingUserId], [FishBillingDate], [BillingType]) VALUES (77, 32, CAST(212.00 AS Decimal(18, 2)), CAST(82370.00 AS Decimal(18, 2)), CAST(82370.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 3, CAST(N'2019-06-23 13:38:03.090' AS DateTime), N'I')
SET IDENTITY_INSERT [dbo].[FishBillingHistory] OFF
SET IDENTITY_INSERT [dbo].[FishSeller] ON 

INSERT [dbo].[FishSeller] ([ID], [Name], [Age], [ImageUrl], [CreatedDate], [CreatedId], [Description], [IsDeleted]) VALUES (9, N'পারভেজ', 25, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:10:54.940' AS DateTime), 1, N'পারভেজ এন্টারপ্রাইজ', 0)
INSERT [dbo].[FishSeller] ([ID], [Name], [Age], [ImageUrl], [CreatedDate], [CreatedId], [Description], [IsDeleted]) VALUES (10, N'এরশাদুল', 20, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:11:33.080' AS DateTime), 1, N'এরশাদুল পাইকার', 0)
INSERT [dbo].[FishSeller] ([ID], [Name], [Age], [ImageUrl], [CreatedDate], [CreatedId], [Description], [IsDeleted]) VALUES (11, N'শ্রী চরন দাদা', 30, N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:12:28.380' AS DateTime), 1, N'কোনাবাড়ী আরদ', 0)
SET IDENTITY_INSERT [dbo].[FishSeller] OFF
SET IDENTITY_INSERT [dbo].[FishSellingReport] ON 

INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (18, CAST(1525.50 AS Decimal(18, 2)), N'মাছ বিক্রি', N'২', CAST(N'2019-03-10' AS Date), CAST(225885.00 AS Decimal(18, 2)), CAST(N'2019-03-10' AS Date), 3, NULL, NULL, NULL, 7, 10, 9, CAST(225885.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (27, CAST(600.00 AS Decimal(18, 2)), N'মাছ বিক্রি', N'1', CAST(N'2019-03-21' AS Date), CAST(89400.00 AS Decimal(18, 2)), CAST(N'2019-03-21' AS Date), 12, CAST(N'2019-03-21' AS Date), 12, NULL, 0, 13, 9, CAST(89400.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (28, CAST(1514.50 AS Decimal(18, 2)), N'মাছ বিক্রি', N'2', CAST(N'2019-03-21' AS Date), CAST(230862.50 AS Decimal(18, 2)), CAST(N'2019-03-21' AS Date), 12, NULL, NULL, NULL, 7, 13, 9, CAST(230862.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (29, CAST(1238.00 AS Decimal(18, 2)), N'মাছ বিক্রি', N'3', CAST(N'2019-03-21' AS Date), CAST(207456.50 AS Decimal(18, 2)), CAST(N'2019-03-21' AS Date), 12, NULL, NULL, NULL, 7, 13, 9, CAST(207456.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (30, CAST(2842.00 AS Decimal(18, 2)), N'মাছ বিক্রি', N'১,2,3', CAST(N'2019-03-23' AS Date), CAST(442116.50 AS Decimal(18, 2)), CAST(N'2019-03-23' AS Date), 12, NULL, NULL, NULL, 7, 13, 9, CAST(442116.50 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (31, CAST(814.00 AS Decimal(18, 2)), N'মাছ বিক্রি', N'1,5', CAST(N'2019-03-29' AS Date), CAST(130440.00 AS Decimal(18, 2)), CAST(N'2019-03-29' AS Date), 12, NULL, NULL, NULL, 7, 13, 9, CAST(130440.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 1)
INSERT [dbo].[FishSellingReport] ([FishSellId], [TotalSellInKG], [HisabName], [GarirName], [SellDate], [TotalSellPrice], [CalculatedDate], [CalculatedById], [CalculationEditedDate], [CalCulationEditedId], [SellNote], [AreaId], [ProjectId], [FishSellerId], [FishAmountPaid], [FishAmountDue], [IsClosedByAdmin]) VALUES (32, CAST(212.00 AS Decimal(18, 2)), N'23 Jan Rup chada Fish', N'Tata4', CAST(N'2019-06-23' AS Date), CAST(82370.00 AS Decimal(18, 2)), CAST(N'2019-06-23' AS Date), 3, NULL, NULL, N'This is a complete project', 8, 21, 9, CAST(82370.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), 0)
SET IDENTITY_INSERT [dbo].[FishSellingReport] OFF
SET IDENTITY_INSERT [dbo].[FishSellingReportMapper] ON 

INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (68, 18, 9, 10, CAST(1375.00 AS Decimal(18, 2)), 1, 1375, CAST(147.00 AS Decimal(18, 2)), CAST(202125.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (69, 18, 9, 14, CAST(39.50 AS Decimal(18, 2)), 3, 0, CAST(180.00 AS Decimal(18, 2)), CAST(7110.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (70, 18, 9, 18, CAST(111.00 AS Decimal(18, 2)), 2, 222, CAST(150.00 AS Decimal(18, 2)), CAST(16650.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (106, 28, 9, 10, CAST(950.00 AS Decimal(18, 2)), 0, 855, CAST(149.00 AS Decimal(18, 2)), CAST(141550.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (107, 28, 9, 14, CAST(113.50 AS Decimal(18, 2)), 1, 0, CAST(200.00 AS Decimal(18, 2)), CAST(22700.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (108, 28, 9, 15, CAST(31.50 AS Decimal(18, 2)), 2, 63, CAST(210.00 AS Decimal(18, 2)), CAST(6615.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (109, 28, 9, 16, CAST(200.00 AS Decimal(18, 2)), 0, 140, CAST(150.00 AS Decimal(18, 2)), CAST(30000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (110, 28, 9, 20, CAST(19.50 AS Decimal(18, 2)), 0, 0, CAST(205.00 AS Decimal(18, 2)), CAST(3997.50 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (111, 28, 9, 22, CAST(200.00 AS Decimal(18, 2)), 2, 400, CAST(130.00 AS Decimal(18, 2)), CAST(26000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (112, 29, 9, 10, CAST(363.50 AS Decimal(18, 2)), 0, 0, CAST(149.00 AS Decimal(18, 2)), CAST(54161.50 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (113, 29, 9, 14, CAST(210.00 AS Decimal(18, 2)), 1, 210, CAST(200.00 AS Decimal(18, 2)), CAST(42000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (114, 29, 9, 15, CAST(10.00 AS Decimal(18, 2)), 0, 5, CAST(200.00 AS Decimal(18, 2)), CAST(2000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (115, 29, 9, 16, CAST(129.00 AS Decimal(18, 2)), 0, 0, CAST(150.00 AS Decimal(18, 2)), CAST(19350.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (116, 29, 9, 19, CAST(32.00 AS Decimal(18, 2)), 0, 16, CAST(145.00 AS Decimal(18, 2)), CAST(4640.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (117, 29, 9, 20, CAST(282.00 AS Decimal(18, 2)), 0, 0, CAST(205.00 AS Decimal(18, 2)), CAST(57810.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (118, 29, 9, 22, CAST(211.50 AS Decimal(18, 2)), 2, 423, CAST(130.00 AS Decimal(18, 2)), CAST(27495.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (119, 27, 9, 10, CAST(600.00 AS Decimal(18, 2)), 0, 540, CAST(149.00 AS Decimal(18, 2)), CAST(89400.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (120, 30, 9, 10, CAST(1501.00 AS Decimal(18, 2)), 0, 0, CAST(149.00 AS Decimal(18, 2)), CAST(223649.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (121, 30, 9, 14, CAST(283.00 AS Decimal(18, 2)), 1, 283, CAST(200.00 AS Decimal(18, 2)), CAST(56600.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (122, 30, 9, 15, CAST(26.00 AS Decimal(18, 2)), 2, 52, CAST(210.00 AS Decimal(18, 2)), CAST(5460.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (123, 30, 9, 16, CAST(600.00 AS Decimal(18, 2)), 0, 396, CAST(150.00 AS Decimal(18, 2)), CAST(90000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (124, 30, 9, 19, CAST(60.50 AS Decimal(18, 2)), 0, 0, CAST(150.00 AS Decimal(18, 2)), CAST(9075.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (125, 30, 9, 20, CAST(120.50 AS Decimal(18, 2)), 0, 0, CAST(205.00 AS Decimal(18, 2)), CAST(24702.50 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (126, 30, 9, 22, CAST(251.00 AS Decimal(18, 2)), 2, 502, CAST(130.00 AS Decimal(18, 2)), CAST(32630.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (127, 31, 9, 10, CAST(385.00 AS Decimal(18, 2)), 0, 0, CAST(149.00 AS Decimal(18, 2)), CAST(57365.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (128, 31, 9, 14, CAST(125.00 AS Decimal(18, 2)), 0, 0, CAST(200.00 AS Decimal(18, 2)), CAST(25000.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (129, 31, 9, 16, CAST(144.00 AS Decimal(18, 2)), 0, 0, CAST(170.00 AS Decimal(18, 2)), CAST(24480.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (130, 31, 9, 19, CAST(133.00 AS Decimal(18, 2)), 0, 0, CAST(150.00 AS Decimal(18, 2)), CAST(19950.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (131, 31, 9, 22, CAST(27.00 AS Decimal(18, 2)), 0, 0, CAST(135.00 AS Decimal(18, 2)), CAST(3645.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (132, 32, 9, 10, CAST(87.00 AS Decimal(18, 2)), 1, 87, CAST(135.00 AS Decimal(18, 2)), CAST(11745.00 AS Decimal(18, 2)))
INSERT [dbo].[FishSellingReportMapper] ([FishSellMapperId], [FishSellReportId], [FishSellerId], [SellFishId], [TotalFishkg], [PiecesPerKG], [TotalPiecesFish], [PricePerKG], [TotalSellPrice]) VALUES (133, 32, 9, 12, CAST(125.00 AS Decimal(18, 2)), 1, 125, CAST(565.00 AS Decimal(18, 2)), CAST(70625.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[FishSellingReportMapper] OFF
SET IDENTITY_INSERT [dbo].[Project] ON 

INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (10, N'মধ্যমণি', 7, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:02:28.410' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (11, N'জাবিরাগারা', 7, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:02:38.610' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (12, N'মধ্যমণি পুকুর', 7, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:02:51.420' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (13, N'চান্দার ক্ষেত', 7, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:03:03.303' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (14, N'মা মৎস্য ', 9, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:03:17.700' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (15, N'নাসির', 9, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:03:30.433' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (16, N'সুখুমুদ্দিন', 9, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:03:51.123' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (17, N'আলিমুদ্দিন', 9, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:04:20.297' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (20, N'সরকার-১', 8, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:05:58.587' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (21, N'সরকার-২', 8, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-10 08:06:15.147' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (27, N'সরকার-৩', 8, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-03-20 08:45:26.830' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (29, N'শেকেরবাইদ-১', 10, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17 09:15:02.833' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (30, N'শেকেরবাইদ-২', 10, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-17 09:15:21.273' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (32, N'সূর্যোদয়', 11, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-19 06:06:08.483' AS DateTime), 1, 0)
INSERT [dbo].[Project] ([ID], [Name], [AreaId], [Land], [Cost], [Time], [ImageUrl], [CreatedDate], [CreatedId], [IsDeleted]) VALUES (33, N'জোড়া পুকুর-১', 11, N'', N'', N'', N'assets/global/img/rams-logo.jpeg', CAST(N'2019-04-19 06:07:07.163' AS DateTime), 1, 0)
SET IDENTITY_INSERT [dbo].[Project] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (1, N'Dhaka', N'Dhaka', N'Dhaka', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', N'Bangladesh', 1, CAST(N'2017-04-04 00:00:00.000' AS DateTime), NULL, 4, 1, CAST(N'2019-01-12 21:19:03.890' AS DateTime), N'admin@gmail.com', N'Admin', 1, NULL, N'update', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, N'07737327171', N'Administrator', N'1207', 1, N'Dhaka', N'1', NULL, N'Rams-logo.png', N'Uploads/User/eccfc5fb-1404-4d4f-9065-c305fff7c7c9-49896089_1998696470224170_3530142991924592640_n.jpg', 127154, N'admin@gmail.com', N'f4d61299-5076-4bc7-8aa0-a5b644424937', 0, NULL, NULL, 0, N'SuperAdmin', NULL, N'103.232.100.78')
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (2, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, 34, CAST(N'2018-01-14 21:04:50.257' AS DateTime), NULL, 4, 1, CAST(N'2019-03-02 22:40:38.367' AS DateTime), N'pirujali@test.com', N'Pirujali', 1, NULL, N'Khamar', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, NULL, N'User', NULL, NULL, NULL, N'1', NULL, N'rams-logo', N'users-logo/137e5650-aa9f-47c6-a69a-b4c115690514.png', 89045, N'pirujali@test.com', N'18534d41-b165-42da-bd33-437d5c2abf4e', 0, NULL, NULL, 0, N'User', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (3, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2018-12-15 11:07:44.617' AS DateTime), NULL, 5, NULL, CAST(N'2018-12-15 11:07:45.697' AS DateTime), N'chabagan@test.com', N'SDFSDF', 1, NULL, N'asdasd', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 4, NULL, N'company User', NULL, NULL, NULL, N'1', N'User', NULL, NULL, NULL, N'Chabagan', N'855dd834-77fa-4fc4-a77e-fdc90a774b2f', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (4, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2018-12-16 05:56:41.417' AS DateTime), NULL, 4, NULL, CAST(N'2018-12-16 05:56:41.417' AS DateTime), N'gasbari@test.com', N'As', 1, NULL, N'Khan', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, NULL, N'User', NULL, NULL, NULL, N'1', NULL, NULL, NULL, NULL, N'gasbari@test.com', N'd865eff7-b759-434d-a690-c30150fdf2bb', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (5, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2018-12-16 21:25:44.110' AS DateTime), NULL, 4, NULL, CAST(N'2019-01-08 16:36:50.363' AS DateTime), N'sfsfgsfg@afads.com', N'sfgsfg', 1, NULL, N'sfgs', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, NULL, N'adfsadsf', NULL, NULL, NULL, N'1', NULL, NULL, N'Uploads/User/7f6c9771-3af3-49dc-ac80-6b94eff4db27-49582277_1969600933148722_4066460243985432576_n.jpg', NULL, N'sfsfgsfg@afads.com', N'8640d6e9-af90-48ce-91cd-185f613917dd', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (6, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2019-01-06 21:36:09.673' AS DateTime), NULL, 4, NULL, CAST(N'2019-01-08 16:49:57.563' AS DateTime), N'testuser@gmail.com', N'User', 1, NULL, N'User', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, NULL, N'chabagan@test.com', NULL, NULL, NULL, N'1', NULL, NULL, N'Uploads/User/9def95b8-c23d-4723-b5aa-435d2ea4fae0-02-black-254x203.jpg', NULL, N'testuser@gmail.com', N'd12d8e19-ea24-4e67-9a55-3295bf2f203f', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (8, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2019-02-16 06:44:02.420' AS DateTime), NULL, 6, NULL, CAST(N'2019-02-16 06:44:02.420' AS DateTime), N'useronetest@test.com', N'userone', 1, NULL, N'test', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 0, NULL, N'test', NULL, NULL, NULL, N'1', N'User', NULL, NULL, NULL, N'useronetest@test.com', N'b6bc8df6-7622-40ad-838d-a71c294414e3', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (10, NULL, NULL, NULL, N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', NULL, NULL, CAST(N'2018-12-15 11:07:44.617' AS DateTime), NULL, 5, NULL, CAST(N'2018-12-15 11:07:45.697' AS DateTime), N'fisherusertest@test.com', N'SDFSDF', 1, NULL, N'asdasd', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 4, NULL, N'company User', NULL, NULL, NULL, N'1', N'User', NULL, NULL, NULL, N'User', N'855dd834-77fa-4fc4-a77e-fdc90a774b2f', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (11, N'Dhaka', N'Dhaka', N'Dhaka', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', N'Bangladesh', 1, CAST(N'2017-04-04 00:00:00.000' AS DateTime), NULL, 4, 1, CAST(N'2019-01-12 21:19:03.890' AS DateTime), N'fishadmintest@gmail.com', N'Admin', 1, NULL, N'update', N'+hdCdZpGjSbghDPURXUsPoGHmHJr2YbTHINkEkuILQ8=', 3, N'07737327171', N'Administrator', N'1207', 1, N'Dhaka', N'1', NULL, N'Rams-logo.png', N'Uploads/User/eccfc5fb-1404-4d4f-9065-c305fff7c7c9-49896089_1998696470224170_3530142991924592640_n.jpg', 127154, N'admin@gmail.com', N'f4d61299-5076-4bc7-8aa0-a5b644424937', 0, NULL, NULL, 0, N'SuperAdmin', NULL, N'103.232.100.78')
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (12, NULL, NULL, NULL, N'4s+AMDBSJozWJytzIQcke3yoEvKxVjwvlx3X/CwgrMbEHgGTMXT35xUloUP7yuuC', NULL, NULL, CAST(N'2019-03-18 08:18:56.317' AS DateTime), NULL, 0, NULL, CAST(N'2019-03-18 08:18:56.317' AS DateTime), N'ashiksarkar@gmail.com', N'Ashik', 1, NULL, N'Sarkar', N'4s+AMDBSJozWJytzIQcke3yoEvKxVjwvlx3X/CwgrMbEHgGTMXT35xUloUP7yuuC', 0, NULL, N'বেগম পুর প্রজেক্ট', NULL, NULL, NULL, N'1', N'User', NULL, NULL, NULL, N'ashiksarkar@gmail.com', N'ddf424e1-01eb-4966-bd5b-f66478217809', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
INSERT [dbo].[Users] ([UserID], [AddressOne], [AddressTwo], [City], [ConfirmPassword], [Country], [CreatedBy], [CreatedDate], [CurrentPassword], [AreaID], [EditedBy], [EditedDate], [EmailAddress], [FirstName], [IsActivated], [IsTemporaryPassword], [LastName], [Password], [ProjectID], [PhoneNumber], [Position], [PostCode], [PublicationStatus], [Religion], [RegistrationConfirmed], [Role], [UserImageCaption], [UserImagePath], [UserImageSize], [UserName], [UserRegistartionGuid], [IsTrialUser], [TrialStartDate], [TrialEndDate], [IsImageUploadedByUser], [UserCreatedBy], [CreatedIP], [EditedIP]) VALUES (13, NULL, NULL, NULL, N'z7XA5DooS2RXHKBfC3BTOpSfDwol6gUZMY4OPIRRYtA=', NULL, NULL, CAST(N'2019-03-20 08:40:13.940' AS DateTime), NULL, 0, NULL, CAST(N'2019-03-20 08:40:13.940' AS DateTime), N'nazmulalam@gmail.com', N'nazmul', 1, NULL, N'alam', N'z7XA5DooS2RXHKBfC3BTOpSfDwol6gUZMY4OPIRRYtA=', 0, NULL, N'sharkar project', NULL, NULL, NULL, N'1', N'User', NULL, NULL, NULL, N'nazmulalam@gmail.com', N'1ef7a5ee-4337-4b79-8597-4ea357add2f7', 0, NULL, NULL, 0, N'CompanyAdmin', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
/****** Object:  StoredProcedure [dbo].[up_GetAdminDashBoardOveriew]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREAte PROCEDURE [dbo].[up_GetAdminDashBoardOveriew]
AS
BEGIN

	
	DECLARE @TotalOveriew TABLE
	(
		TotalFishSell decimal(18,2),
		TotalFeedBuy decimal(18,2),
		TotalFeedDistribute decimal(18,2),
		TotalRecord decimal(18,2)
	)

	DECLARE @TotalFishSell AS decimal(18,2)
	DECLARE @TotalFeedBuy AS decimal(18,2)
	DECLARE @TotalFeedDistribute AS decimal(18,2)
	DECLARE @TotalRecord AS decimal(18,2)

	SELECT @TotalFishSell = [TotalSellPrice] from [dbo].[FishSellingReport];
	SELECT @TotalFeedBuy = [SellingFeedTotalPrice] from [dbo].[FeedSellingReport];
	SELECT @TotalFeedDistribute = [FeedDistributionTotalWeight] from [dbo].[FeedDistributionReports];
	set @TotalRecord = '250.55'

	INSERT INTO @TotalOveriew (TotalFishSell,TotalFeedBuy,TotalFeedDistribute,TotalRecord) Values(@TotalFishSell, @TotalFeedBuy,@TotalFeedDistribute,@TotalRecord)
	select * from @TotalOveriew
END




GO
/****** Object:  StoredProcedure [dbo].[up_GetCostExpandName]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetCostExpandName] 
( 
	@searchText nvarchar(500)
) 

AS 
BEGIN 

	SELECT 
	f.ID, 
	f.Name, 
	[dbo].MyHTMLDecode([dbo].[udf_StripHTML](f.Description)) as Description, 
	f.ImageUrl, 
	convert(varchar(10),f.CreatedDate,103) CreaetdDate, 
	f.CreatedId 

	from [Expend] f 

	where 
	( ( Convert(nvarchar(100),f.ID) = @searchText ) 

	OR ( (f.Name LIKE +'%'+ @searchText +'%' ) 
	OR (f.Description LIKE +'%'+ @searchText ) 
	OR (convert(nvarchar(10),f.CreatedDate,103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0



END





GO
/****** Object:  StoredProcedure [dbo].[up_GetFarmRentalReportsBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFarmRentalReportsBySearchParam] 
( 
	@projectId  varchar (10),
	@areaId   varchar (10)
) 

AS 
BEGIN 

	SELECT
	d.[FarmRentalReportID],
	d.[FarmRentalReportName],
	d.[FarmRentalDetails],
	convert(nvarchar(15),d.[FarmRentalDate],106) AS FarmRentalDate,
	--(select t.[Name] from  [dbo].[Project] t where t.[ID]=d.[FarmRentalProjectID]) as ProjectName,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FarmRentalLandAmount])) As FarmRentalLandAmount,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FarmRentalMainFee])) As FarmRentalMainFee,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FarmRentalTotalFee])) As FarmRentalTotalFee,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FarmRentalServieFee])) As FarmRentalServieFee,
	convert(nvarchar(15),d.[CreatedDate],106) AS CreatedDate,
	[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId](d.[AreaId],d.[ProjectId]) ProjectName

	FROM
	[dbo].[FarmRentalReports] d

	WHERE 
	(d.[ProjectId] = COALESCE(NULLIF(@projectId, ''), d.[ProjectId])
	and
	d.[AreaId] = COALESCE(NULLIF(@areaId, ''), d.[AreaId]))

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedBillingReportByFeedId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedBillingReportByFeedId] 
( 
	@feedId varchar (10)
) 

AS 
BEGIN 

	IF @feedId !=''
		
		BEGIN

			SELECT
			mp.[FeedId],
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalPrice]))) TOTALPriceString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedTotalBags]))) FeedTotalBagsString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedBagsWeight]))) FeedBagsWeightString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalWeight]))) TotalWeightString,
			[dbo].[uf_GetFeedNameByFeedId](mp.[FeedId]) FeedName,
			sum(mp.[TotalPrice]) TOTALPrice,
			sum(mp.[FeedTotalBags]) FeedTotalBags,
			sum(mp.[FeedBagsWeight]) FeedBagsWeight,
			sum(mp.[TotalWeight]) TotalWeight

			FROM
			[dbo].[FeedSellingReport] f
			Inner join [dbo].[FeedSellingReportMapper] mp on mp.[FeedSellingReportId]=f.[FeedSellingReportId]
			where mp.[FeedId]=@feedId
			group by mp.[FeedId]

		END
	ELSE

		BEGIN

			SELECT
			mp.[FeedId],
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalPrice]))) TOTALPriceString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedTotalBags]))) FeedTotalBagsString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedBagsWeight]))) FeedBagsWeightString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalWeight]))) TotalWeightString,
			[dbo].[uf_GetFeedNameByFeedId](mp.[FeedId]) FeedName,
			sum(mp.[TotalPrice]) TOTALPrice,
			sum(mp.[FeedTotalBags]) FeedTotalBags,
			sum(mp.[FeedBagsWeight]) FeedBagsWeight,
			sum(mp.[TotalWeight]) TotalWeight

			FROM
			[dbo].[FeedSellingReport] f
			Inner join [dbo].[FeedSellingReportMapper] mp on mp.[FeedSellingReportId]=f.[FeedSellingReportId]
			group by mp.[FeedId]
		END


END



GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedBuyingChartReportForAdmin]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedBuyingChartReportForAdmin] 
AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[SellingFeedTotalPrice])) As SellingFeedPricePerKg,
	convert(varchar(15), c.[SellingFeedCalculationDate],106) CalculationDate
	FROM [dbo].[FeedSellingReport] c
	group by c.[SellingFeedCalculationDate]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedBuyingChartReportForUser]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedBuyingChartReportForUser] 
( 
	@areaId int,
	@projectId int
) 

AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[SellingFeedTotalPrice])) As SellingFeedPricePerKg,
	convert(varchar(15), c.[SellingFeedCalculationDate],106) as CalculationDate
	FROM [dbo].[FeedSellingReport] c
	-- where c.[SellingFeedAreaId]=@areaId and c.[SellingFeedProjectId]=@projectId
	where c.[AreaId]=@areaId and c.[ProjectId]=@projectId
	group by c.[SellingFeedCalculationDate]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedBuyingReportByFeedCategory]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedBuyingReportByFeedCategory] 
( 
	@areaId int,
	@projectId int
) 

AS 
BEGIN 
	select
	convert(nvarchar(500),sum(c.[SellingFeedTotalPrice])) As SellingFeedTotalPrice,
	--[dbo].[uf_GetFeedCategorynameByFeedCategoryId] (c.SellingReportFeedCategoryId) as FeedCategory
	'TEst' as FeedCategory
	FROM [dbo].[FeedSellingReport] c
	--where c.[SellingFeedAreaId]=@areaId and c.[SellingFeedProjectId]=@projectId
	where c.[AreaId]=@areaId and c.[ProjectId]=@projectId
	group by c.[SellingFeedCalculationDate]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedBuyingReportByFeedCategoryForAdmin]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedBuyingReportByFeedCategoryForAdmin] 
AS 
BEGIN 
	select
	convert(nvarchar(500),sum(c.[TotalPrice])) As SellingFeedTotalPrice,
	[dbo].[uf_GetFeedCategorynameByFeedCategoryId] (c.FeedCategoryId)FeedCategory
	FROM [dbo].[FeedSellingReportMapper] c
	group by c.FeedCategoryId
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedCategorySearchResult]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedCategorySearchResult] 
( 
	@searchText nvarchar(500), 
	@pageNumber int, 
	@pageSize int 
) 

AS 
BEGIN 

	SELECT 
	f.[FeedCategoryId], 
	f.[FeedCategoryName], 
	f.[FeedCategoryDetails], 
	f.[FeedCategoryImageUrl],
	convert(varchar(10),f.[CreatedDate],103) CreaetdDate, 
	f.[CreatedId] 

	from [dbo].[FeedCategories] f 

	where 
	( ( Convert(varchar(100),f.[FeedCategoryId]) = @searchText ) 

	OR ( (f.[FeedCategoryName] LIKE +'%'+ @searchText +'%' )
	OR (convert(varchar(10),f.[CreatedDate],103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0


END





GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedDistributionPieChart]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedDistributionPieChart] 
AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[FeedDistributionTotalWeight])/1000) As TotalWeight,
	[dbo].[uf_GetAreaNameByAreaId](c.[AreaId]) AreaName
	FROM [dbo].[FeedDistributionReports] c
	group by c.[AreaId]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedDistributionReportsByAreaId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedDistributionReportsByAreaId] 
( 
	@areaId varchar (10),
	@projectId varchar (10)
) 

AS 
BEGIN 
	
	SELECT
	d.[FeedDistributionReportId],
	d.[FeedDistributionName],
	d.[FeedDistributionQuantityId],
	convert(nvarchar(15),d.[FeedDistributionDate],106) AS FeedDistributionDate,
	(select t.[FeedCategoryName] from [dbo].[FeedCategories] t where t.[FeedCategoryId]=d.[FeedDistributionFeedategoryId]) as FeedCategoryName,
	convert(nvarchar(100),d.[FeedDistributionSakNumber]) As FeedDistributionSakNumber,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FeedDistributionTotalWeight])) As FeedDistributionTotalWeight,
	convert(nvarchar(15),d.[CreatedDate],106) AS CreatedDate,
	[dbo].[uf_GetFeedNameWithCategoryByFeedIdAndCatId](d.[FeedDistributionFeedId],d.[FeedDistributionFeedategoryId]) FeedNameWithCat,
	[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId](d.[AreaId],d.[ProjectId]) ProjectName

	FROM
	[dbo].[FeedDistributionReports] d
	where
	d.IsActive = 1 
	and 
	(d.[AreaId] LIKE '%' + @areaId + '%'  OR  d.[AreaId] LIKE '%'+ @areaId OR  d.[AreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)
	and 
	(d.[ProjectId] LIKE '%' + @projectId + '%'  OR  d.[ProjectId] LIKE '%'+ @projectId OR  d.[ProjectId] LIKE @projectId + '%' OR @projectId = '' OR @projectId IS NULL)

	Order by d.[FeedDistributionDate] desc

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedDistributionReportsBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedDistributionReportsBySearchParam] 
( 
	@feedId varchar (10),
	@categoryId varchar (10),
	@areaId varchar (10),
	@projectId varchar (10),
	@calculationName nvarchar(max)
) 

AS 
BEGIN 

	--if @isPartial = 1
		--BEGIN
			SELECT
			d.[FeedDistributionReportId],
			d.[FeedDistributionName],
			d.[FeedDistributionQuantityId],
			convert(nvarchar(15),d.[FeedDistributionDate],106) AS FeedDistributionDate,
			(select t.[FeedCategoryName] from [dbo].[FeedCategories] t where t.[FeedCategoryId]=d.[FeedDistributionFeedategoryId]) as FeedCategoryName,
			convert(nvarchar(100),d.[FeedDistributionSakNumber]) As FeedDistributionSakNumber,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FeedDistributionTotalWeight])) As FeedDistributionTotalWeight,
			convert(nvarchar(15),d.[CreatedDate],106) AS CreatedDate,
			[dbo].[uf_GetFeedNameWithCategoryByFeedIdAndCatId](d.[FeedDistributionFeedId],d.[FeedDistributionFeedategoryId]) FeedNameWithCat,
			[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId](d.[AreaId],d.[ProjectId]) ProjectName

			FROM
			[dbo].[FeedDistributionReports] d
			where
			d.IsActive = 1 
		   and (d.[FeedDistributionFeedId] LIKE '%' + @feedId + '%'  OR  d.[FeedDistributionFeedId] LIKE '%'+ @feedId OR  d.[FeedDistributionFeedId] LIKE @feedId + '%' OR @feedId = '' OR @feedId IS NULL)
		   and (d.[FeedDistributionFeedategoryId] LIKE '%' + @categoryId + '%'  OR  d.[FeedDistributionFeedategoryId] LIKE '%'+ @categoryId OR  d.[FeedDistributionFeedategoryId] LIKE @categoryId + '%' OR @categoryId = '' OR @categoryId IS NULL)
		   and (d.[AreaId] LIKE '%' + @areaId + '%'  OR  d.[AreaId] LIKE '%'+ @areaId OR  d.[AreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)
		   or (d.[ProjectId] LIKE '%' + @projectId + '%'  OR  d.[ProjectId] LIKE '%'+ @projectId OR  d.[ProjectId] LIKE @projectId + '%' OR @projectId = '' OR @projectId IS NULL)

		   --and(d.[FeedDistributionName] LIKE '%' + @calCulationName + '%'  OR d.[FeedDistributionName] LIKE '%'+ @calCulationName OR d.[FeedDistributionName] LIKE @calCulationName + '%' OR @calCulationName = '' OR @calCulationName IS NULL)

		 --   OR u.EmailAddress LIKE '%' + @searchText + '%'  OR u.EmailAddress LIKE '%'+ @searchText OR u.EmailAddress LIKE @searchText + '%'
			--OR u.CreatedIP = @searchText OR u.EditedIP=@searchText		
		

			--WHERE 
			--(
			--	d.IsActive = 1 or
			--	d.[FeedDistributionFeedId] = COALESCE(NULLIF(@feedId, ''), d.[FeedDistributionFeedId])
			--	or
			--	d.[FeedDistributionFeedategoryId] = COALESCE(NULLIF(@categoryId, ''), d.[FeedDistributionFeedategoryId])
			--	or
			--	d.[AreaId] = COALESCE(NULLIF(@areaId, ''), d.[AreaId])
			--	or
			--	d.[ProjectId] = COALESCE(NULLIF(@projectId, ''), d.[ProjectId])
			--) 
			--and
			--(
			--	convert(nvarchar(10), d.[FeedDistributionDate],103) = COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(10), d.[FeedDistributionDate],103))
			--	OR
			--	convert(nvarchar(15), d.[FeedDistributionDate],106) like +'%'+  COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(15), d.[FeedDistributionDate],106))+'%'
			--	or
			--	d.[FeedDistributionName] like +'%'+ COALESCE(NULLIF(@calculationName, ''), d.[FeedDistributionName]) +'%'
			--)
				
		--END


	--if @isPartial = 0

	--	BEGIN
	--		SELECT
	--		d.[FeedDistributionReportId],
	--		d.[FeedDistributionName],
	--		d.[FeedDistributionQuantityId],
	--		convert(nvarchar(15),d.[FeedDistributionDate],106) AS FeedDistributionDate,
	--		(select t.[FeedCategoryName] from [dbo].[FeedCategories] t where t.[FeedCategoryId]=d.[FeedDistributionFeedategoryId]) as FeedCategoryName,
	--		convert(nvarchar(100),d.[FeedDistributionSakNumber]) As FeedDistributionSakNumber,
	--		dbo.uf_AddThousandSeparators(convert(nvarchar(100),d.[FeedDistributionTotalWeight])) As FeedDistributionTotalWeight,
	--		convert(nvarchar(15),d.[CreatedDate],106) AS CreatedDate,
	--		[dbo].[uf_GetFeedNameWithCategoryByFeedIdAndCatId](d.[FeedDistributionFeedId],d.[FeedDistributionFeedategoryId]) FeedNameWithCat

	--		FROM
	--		[dbo].[FeedDistributionReports] d where d.IsActive = 1
	--	END


END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedPurchasePieChart]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedPurchasePieChart] 
AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[TotalWeight])/1000) As TotalWeight,
	[dbo].[uf_GetAreaNameByAreaId](c.[MapperAreaId]) AreaName
	FROM [dbo].[FeedSellingReportMapper] c
	group by c.[MapperAreaId]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedPurchaseReportByAreaId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedPurchaseReportByAreaId] 
( 
	
	@areaId varchar (10)
) 

AS 
BEGIN 

	SELECT
	DISTINCT c.[FeedSellingReportId],
	c.[SellingFeedReportNumber],
	c.[SellingReportName],
	c.[SellingReportName] + ' ('+c.[SellingFeedReportNumber]+')' AS FullName,
	convert(nvarchar(15),c.SellingFeedCalculationDate,106) AS SellingFeedCalculationDate,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.TotalWeight)) As SellingFeedTotalWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.TotalPrice)) As SellingFeedTotalPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.FeedAmountPaid)) As FeedAmountPaid,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.FeedAmountDue)) As FeedAmountDue,
	convert(nvarchar(15),c.SellingFeedCreateDate,106) AS SellingFeedCreateDate,
	[dbo].[uf_GetFeedNameByFeedId](mp.[FeedId]) +' ('+ [dbo].[uf_GetFeedCategorynameByFeedCategoryId](mp.feedcategoryid)+')' AS FeedNames,
	[dbo].[uf_GetAreaNameByAreaId](mp.[mapperAreaId]) AS ProjectName

	FROM [dbo].[FeedSellingReport] c

	left outer JOIN [dbo].[FeedSellingReportMapper] mp ON mp.[FeedSellingReportId] = c.[FeedSellingReportId]

	WHERE 
	 (mp.[MapperAreaId] LIKE '%' + @areaId + '%'  OR  mp.[MapperAreaId] LIKE '%'+ @areaId OR  mp.[MapperAreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)
	

END



GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedPurchaseReportBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedPurchaseReportBySearchParam] 
( 
	@feedId varchar (10),
	@catId varchar (10),
	@areaId varchar (10),
	@projectId varchar (10),
	@calculationName nvarchar(max)
) 

AS 
BEGIN 

	SELECT
	DISTINCT c.[FeedSellingReportId],
	c.[SellingFeedReportNumber],
	c.[SellingReportName],
	c.[SellingReportName] + ' ('+c.[SellingFeedReportNumber]+')' AS FullName,
	convert(nvarchar(15),c.SellingFeedCalculationDate,106) AS SellingFeedCalculationDate,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.SellingFeedTotalWeight)) As SellingFeedTotalWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.SellingFeedTotalPrice)) As SellingFeedTotalPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.FeedAmountPaid)) As FeedAmountPaid,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.FeedAmountDue)) As FeedAmountDue,
	convert(nvarchar(15),c.SellingFeedCreateDate,106) AS SellingFeedCreateDate,
	[dbo].[uf_GetFeedNamesWithCommaByPurchaseId](c.[FeedSellingReportId]) AS FeedNames,
	[dbo].[uf_GetAreaNamesWithCommaByPurchaseId](c.[FeedSellingReportId]) ProjectName

	FROM [dbo].[FeedSellingReport] c

	left outer JOIN [dbo].[FeedSellingReportMapper] mp ON mp.[FeedSellingReportId] = c.[FeedSellingReportId]

	WHERE 
	1=1
	--order by c.SellingFeedCalculationDate ASC
	and (mp.[MapperAreaId] LIKE '%' + @areaId + '%'  OR  mp.[MapperAreaId] LIKE '%'+ @areaId OR  mp.[MapperAreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)
		--(convert(nvarchar(10), c.[SellingFeedCalculationDate],103) = COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(10), c.[SellingFeedCalculationDate],103))
		--	OR
		--	convert(nvarchar(15), c.[SellingFeedCalculationDate],106) like +'%'+  COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(15), c.[SellingFeedCalculationDate],106))+'%'
		--	OR
		--	c.[SellingFeedReportNumber] like +'%'+ COALESCE(NULLIF(@calculationName, ''), c.[SellingFeedReportNumber]) +'%'
		--	or
		--	c.[SellingReportName] like +'%'+ COALESCE(NULLIF(@calculationName, ''), c.[SellingReportName]) +'%')
		--	and
		--(
		--	mp.[FeedId] = COALESCE(NULLIF(@feedId, ''), mp.[FeedId])
		--	and
		--	mp.[FeedCategoryId] = COALESCE(NULLIF(@catId, ''), mp.[FeedCategoryId])
		--	and
		--	mp.[MapperAreaId] = COALESCE(NULLIF(@areaId, ''), mp.[MapperAreaId])
		--	--and
		--	--c.[ProjectId] = COALESCE(NULLIF(@projectId, ''), c.[ProjectId])
		--)

	

END



GO
/****** Object:  StoredProcedure [dbo].[up_GetFeedPurchaseSingleReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFeedPurchaseSingleReport] 
( 
	@reportId int
) 

AS 
BEGIN 

	select
	[dbo].[uf_GetAreaNameByAreaId](mp.mapperAreaId) AreaName,
	[dbo].[uf_GetFeedNameByFeedId](mp.[FeedId]) FeedName,
	[dbo].[uf_GetFeedCategorynameByFeedCategoryId](mp.[FeedCategoryId]) CategoryName,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[FeedTotalBags])) As FeedTotalBags,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[FeedBagsWeight])) As FeedBagsWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[TotalWeight])) As TotalWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[TotalPrice])) As TotalPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[PricePerKg])) As PricePerKg,
	mp.FeedSellingReportId

	from 

	[dbo].[FeedSellingReportMapper] mp

	where mp.FeedSellingReportId=@reportId

END



GO
/****** Object:  StoredProcedure [dbo].[up_GetFishBillingHistoryBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishBillingHistoryBySearchParam] 
( 
	@sellerId int,
	@startDate date,
	@endDate date,
	@isPartial int
) 

AS 
BEGIN 

	if @isPartial = 0

		BEGIN
		select
		b.FishBillingFishSellId,
		dbo.uf_AddThousandSeparators(b.[FishBillingFishInKG]) FishBillingFishInKG,
		dbo.uf_AddThousandSeparators(b.[FishBillingTotalPrice]) FishBillingTotalPrice,
		dbo.uf_AddThousandSeparators(b.[FishBillingPaidAmount]) FishBillingPaidAmount,
		dbo.uf_AddThousandSeparators(b.[FishBillingDueAmount]) FishBillingDueAmount,
		CONVERT(VARCHAR(20),  f.SellDate,106) as SellDate,
		CONVERT(VARCHAR(20),  b.FishBillingDate,106) as FishBillingDate,
		[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](f.[FishSellId]) as SellingFishName,
		f.FishSellerId,
		[dbo].[uf_GetFishSellerNameByFishId](f.FishSellerId) as SellerName
		from FishBillingHistory b
		INNER JOIN [dbo].[FishSellingReport] f on f.FishSellId=b.FishBillingFishSellId
		order by b.FishBillingFishSellId desc

		END

	if @isPartial = 1 and @startDate != '' and @endDate !='' and @sellerId != '' 
		BEGIN
			select
			b.FishBillingFishSellId,
			dbo.uf_AddThousandSeparators(b.[FishBillingFishInKG]) FishBillingFishInKG,
			dbo.uf_AddThousandSeparators(b.[FishBillingTotalPrice]) FishBillingTotalPrice,
			dbo.uf_AddThousandSeparators(b.[FishBillingPaidAmount]) FishBillingPaidAmount,
			dbo.uf_AddThousandSeparators(b.[FishBillingDueAmount]) FishBillingDueAmount,
			CONVERT(VARCHAR(20),  f.SellDate,106) as SellDate,
			CONVERT(VARCHAR(20),  b.FishBillingDate,106) as FishBillingDate,
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](f.[FishSellId]) as SellingFishName,
			f.FishSellerId,
			[dbo].[uf_GetFishSellerNameByFishId](f.FishSellerId) as SellerName
			from FishBillingHistory b
			INNER JOIN [dbo].[FishSellingReport] f on f.FishSellId=b.FishBillingFishSellId
			WHERE (
				b.FishBillingDate >=@startDate AND b.FishBillingDate  <= @endDate AND f.FishSellerId = @sellerId
			)
			order by b.FishBillingFishSellId desc

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishBillingHistoryBySellerId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishBillingHistoryBySellerId] 
( 
	@sellerId int
) 

AS 
BEGIN 

	select
	b.FishBillingFishSellId,
	dbo.uf_AddThousandSeparators(b.[FishBillingFishInKG]) FishBillingFishInKG,
	dbo.uf_AddThousandSeparators(b.[FishBillingTotalPrice]) FishBillingTotalPrice,
	dbo.uf_AddThousandSeparators(b.[FishBillingPaidAmount]) FishBillingPaidAmount,
	dbo.uf_AddThousandSeparators(b.[FishBillingDueAmount]) FishBillingDueAmount,
	CONVERT(VARCHAR(20),  f.SellDate,106) as SellDate,
	CONVERT(VARCHAR(20),  b.FishBillingDate,106) as FishBillingDate,
	[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](f.[FishSellId]) as SellingFishName,
	f.FishSellerId,
	[dbo].[uf_GetFishSellerNameByFishId](f.FishSellerId) as SellerName
	from FishBillingHistory b
	INNER JOIN [dbo].[FishSellingReport] f on f.FishSellId=b.FishBillingFishSellId
	where 
	f.FishSellerId=@sellerId
	order by b.FishBillingDate,b.[FishBillingDueAmount] desc
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellerPDFInfo]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellerPDFInfo] 
( 
	@fishSellId int
) 

AS 
BEGIN 

	select
	[dbo].[uf_GetFishNameByFishId](mp.[SellFishId]) FishName,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[TotalFishkg])) As TotalFishkg,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),mp.[TotalSellPrice])) As TotalSellPrice
	from [dbo].[FishSellingReportMapper] mp

	where mp.[FishSellReportId] = @fishSellId

	--select [dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,
	--[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](FishSellId) SellingFishName,
	--dbo.uf_AddThousandSeparators(convert(nvarchar(500), TotalSellInKG)) TotalSellInKG, 
	--projectid, 
	--SellDate,
	--FishSellerId, 
	--dbo.uf_AddThousandSeparators(TotalSellPrice) as totalAmount, 
	--dbo.uf_AddThousandSeparators(FishAmountPaid) as PaidAmount,
	--dbo.uf_AddThousandSeparators(FishAmountDue) as DueAmount,
	--FishSellId
	--from FishSellingReport
	--where SellDate= @SellDate and projectid=@projectid and FishSellerId=@FishSellerId
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellerPDFInfoTotalCalculation]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellerPDFInfoTotalCalculation] 
( 
	--@SellDate date,
	--@projectid int,
	--@FishSellerId int
	@fishSellId int
) 

AS 
BEGIN 

	--select 
	--dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) TotalAmount,
	--dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount,
	--dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount
	--from FishSellingReport
	--where SellDate= @SellDate and projectid=@projectid and FishSellerId=@FishSellerId

	select
	dbo.uf_AddThousandSeparators(f.[FishAmountPaid]) PaidAmount,
	dbo.uf_AddThousandSeparators(f.[FishAmountDue]) DueAmount,
	dbo.uf_AddThousandSeparators(f.[TotalSellPrice]) TotalAmount

	from [dbo].[FishSellingReport] f where f.[FishSellId]=@fishSellId


END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellerSearchResults]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellerSearchResults] 
( 
	@searchText nvarchar(500)
) 

AS 
BEGIN 

	SELECT 
	f.[ID], 
	f.[Name], 
	f.[Age], 
	[dbo].MyHTMLDecode([dbo].[udf_StripHTML](f.Description)) as Description, 
	f.[ImageUrl],
	convert(varchar(10),f.[CreatedDate],103) CreaetdDate, 
	f.[CreatedId] 

	from [dbo].[FishSeller] f 

	where 
	( ( Convert(varchar(100),f.[ID]) = @searchText ) 
	OR ( (f.[Name] LIKE +'%'+ @searchText +'%' )
	OR (convert(varchar(10),f.[CreatedDate],103) LIKE @searchText +'%') ) )
	AND 
	f.IsDeleted =0



END





GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingBillingAmountPaidAmountAndDueAmountBySellId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingBillingAmountPaidAmountAndDueAmountBySellId] 
( 
	@fishSellId int
) 

AS 
BEGIN 

	select
	CONVERT(VARCHAR(20),  SellDate,106) as SellDate,
	[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId]([FishSellId]) as SellingFishName,
	[dbo].[uf_GetFishSellerNameByFishId](FishSellerId) as SellerName,
	dbo.uf_AddThousandSeparators(FishAmountPaid) as FishAmountPaid
	,dbo.uf_AddThousandSeparators(FishAmountDue) as FishAmountDue
	,dbo.uf_AddThousandSeparators(TotalSellPrice) as TotalSellPrice
	,dbo.uf_AddThousandSeparators(TotalSellInKG) as TotalSellInKG,FishSellId
	from [dbo].[FishSellingReport]
	where [FishSellerId]=@fishSellId and IsClosedByAdmin=0
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingChartReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[up_GetFishSellingChartReport]
	
AS
BEGIN
	SELECT 
	convert(nvarchar(500),sum([TotalSellPrice])) As TotalSell,
	[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId]([AreaId],[ProjectId]) AS ProjectName
	FROM [dbo].[FishSellingReport]
	GROUP BY [AreaId],[ProjectId]
	ORDER BY TotalSell
END





GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingChartReportForUser]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingChartReportForUser] 
( 
	@areaId int,
	@projectId int
) 

AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[TotalSellPrice])) As TotalSellPrice,
	convert(varchar(15), c.[SellDate],106) CalculatedDate
	FROM [dbo].[FishSellingReport] c
	 where c.[AreaId]=@areaId --and c.[ProjectId]=@projectId
	group by c.[SellDate]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingColumnChartReportForAdmin]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingColumnChartReportForAdmin]
AS 
BEGIN 

	select
	convert(nvarchar(500),sum(c.[TotalSellPrice])) As TotalSellPrice,
	convert(varchar(15), c.[SellDate],106) CalculatedDate
	FROM [dbo].[FishSellingReport] c
	group by c.[SellDate]
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingMapperListBySellId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingMapperListBySellId] 
( 
	@fishSellId int
) 

AS 
BEGIN 

	select 
	dbo.uf_AddThousandSeparators(mp.TotalFishkg) as TotalFishkg
	,dbo.uf_AddThousandSeparators(mp.TotalPiecesFish) as TotalPiecesFish
	,dbo.uf_AddThousandSeparators(mp.PricePerKG) as PricePerKG
	,dbo.uf_AddThousandSeparators(mp.TotalSellPrice) as TotalSellPrice
	,[dbo].[uf_GetFishNameByFishId](mp.SellFishId) as FishName
	from [dbo].[FishSellingReportMapper] mp

	where mp.FishSellReportId=@fishSellId


END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingReportByFishId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingReportByFishId] 
( 
	@areaId int,
	@projectId int
) 

AS 
BEGIN 
	select
	convert(nvarchar(500),sum(c.[TotalSellPrice])) As TotalSellPrice,
	[dbo].[uf_GetFishNameByFishId](c.SellFishId) FishName
	FROM [dbo].[FishSellingReportMapper] c
	Inner join FishSellingReport f on f.FishSellId =c.FishSellReportId
	where f.[AreaId]=@areaId
	group by c.SellFishId
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingReportByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingReportByParam] 
( 
	@areaId int,
	@projectId int,
	@calCulationName nvarchar(max),
	@isPartial int=1
) 

AS 
BEGIN 

	if @isPartial = 1

		BEGIN

			
			SELECT
			c.[FishSellId],
			c.[HisabName],
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,
			convert(nvarchar(100),c.[TotalSellInKG]) As TotalSellInKG,
			[dbo].[uf_GetFishSellerNameByFishId](c.FishSellerId) SellerName,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			[dbo].[uf_GetProjectNameByProjectId](c.[ProjectId]) As ProjectName,
			[dbo].[uf_GetAreaNameByAreaId] (c.[AreaId]) as AreaName,
			[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId](c.[AreaId],c.[ProjectId]) ProjectWithArea,
			c.[AreaId],
			c.[ProjectId],
			'All' As AllFishName

			FROM [dbo].[FishSellingReport] c

			WHERE 
				(
					IsClosedByAdmin = 0 and
					c.[ProjectId] = COALESCE(NULLIF(@projectId, ''), c.[ProjectId])
					and
					c.[AreaId] = COALESCE(NULLIF(@areaId, ''), c.[AreaId])
				)
				and 
				(
					convert(nvarchar(10), c.[SellDate],103) = COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(10), c.[SellDate],103))
					OR
					convert(nvarchar(15), c.[SellDate],106) like +'%'+  COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(15), c.[SellDate],106))+'%'
					OR
					[dbo].[uf_GetFishSellerNameByFishId](c.FishSellerId) like +'%'+ COALESCE(NULLIF(@calCulationName, ''),  [dbo].[uf_GetFishSellerNameByFishId](c.FishSellerId)) +'%'
					OR
					c.[HisabName] like +'%'+ COALESCE(NULLIF(@calCulationName, ''), c.[HisabName]) +'%'
					OR
					c.[GarirName] like +'%'+ COALESCE(NULLIF(@calCulationName, ''), c.[GarirName]) +'%'
				)
			 
			order by c.[SellDate] ASC
		END


	if @isPartial = 0

		BEGIN

			SELECT
			c.[FishSellId],
			c.[HisabName],
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,
			convert(nvarchar(100),c.[TotalSellInKG]) As TotalSellInKG,
			[dbo].[uf_GetFishSellerNameByFishId](c.FishSellerId) SellerName,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			[dbo].[uf_GetProjectNameByProjectId](c.[ProjectId]) As ProjectName,
			[dbo].[uf_GetAreaNameByAreaId] (c.[AreaId]) as AreaName,
			[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId](c.[AreaId],c.[ProjectId]) ProjectWithArea,
			c.[AreaId],
			c.[ProjectId],
			'All' As AllFishName

			FROM [dbo].[FishSellingReport] c
			
			where --c.[AreaId]=@areaId --and c.[ProjectId]=@projectId
			 IsClosedByAdmin = 0

			order by c.[FishSellId] desc

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingReportForAdminByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingReportForAdminByParam] 
( 
	@startDate date,
	@endDate Date,
	@isPartial int=1,
	@areaId int,
	@projectId int
) 

AS 
BEGIN 

	if @isPartial = 1 AND (@startDate !='' AND @endDate !='' AND @projectId !='' AND @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId]
			,c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >=@startDate AND c.[SellDate] <=@endDate AND c.[ProjectId] =@projectId AND c.[AreaId]=@areaId
			)
			order by c.[SellDate] ASC

		END

	if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' AND @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[ProjectId] = @projectId
				
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[AreaId]=@areaId
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
			)
			order by c.[SellDate] ASC

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[AreaId]=@areaId
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
			)
			order by c.[SellDate] ASC

		END
		
		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
			)
			order by c.[SellDate] ASC

		END




	  if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
				
			)
			order by c.[SellDate] ASC

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
				
			)
			order by c.[SellDate] ASC

		END


		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[ProjectId] = @projectId )
				AND
				(c.[AreaId]=@areaId)
				
			)
			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE c.[ProjectId] = @projectId

			order by c.[SellDate] ASC

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[AreaId]=@areaId)
				
			)
			order by c.[SellDate] ASC

		END


	if @isPartial = 0

		BEGIN

			SELECT
			c.[FishSellId],
			[dbo].[uf_GetFishNameListWithSeperatedByCommaBySellingId](c.[FishSellId]) as SellingFishName,
			convert(nvarchar(15),c.[SellDate],106) AS FishSellingDate,			
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellInKG])) As TotalSellInKG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[TotalSellPrice])) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountPaid])) As FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(100),c.[FishAmountDue])) As FishAmountDue,
			(select t.Name + ' (' + convert(nvarchar(100),t.Age) from FishSeller t where t.ID = c.FishSellerId) SellerName,
			convert(nvarchar(15),c.[CalculatedDate],106) AS CalculatedDate,
			c.[AreaId],
			c.[ProjectId],c.HisabName

			FROM [dbo].[FishSellingReport] c

			order by c.[FishSellId] desc

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingSellerReportForAdminByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingSellerReportForAdminByParam] 
( 
	@startDate date,
	@endDate Date,
	@isPartial int=1,
	@projectId int,
	@sellerID int
) 

AS 
BEGIN 

	if @isPartial = 1 

		BEGIN

			select CONVERT(VARCHAR(20),  c.SellDate) as SDate, [dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
			[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName
			,c.FishSellId
			from FishSellingReport c 
			WHERE
			  c.[FishSellerId] = @sellerID OR @sellerID = '' OR @sellerID IS NULL 
			 -- OR (c.[SellDate] BETWEEN @startDate AND @endDate) OR @endDate = '' OR @endDate IS NULL OR @startDate = '' OR @startDate IS NULL
			  --OR c.[SellDate] >=@startDate OR @startDate = '' OR @startDate IS NULL
			 -- OR c.[SellDate] <=@endDate OR @endDate = '' OR @endDate IS NULL
			  group by SellDate,projectid,FishSellerId,FishSellId 

		END

	--if @isPartial = 1 

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate, [dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName
	--		,c.FishSellId
	--		from FishSellingReport c 
	--		WHERE
	--		  c.[FishSellerId] LIKE '%' + @sellerID + '%'  OR c.[FishSellerId] LIKE '%'+ @sellerID OR c.[FishSellerId] LIKE @sellerID + '%'
	--			   OR @sellerID = '' OR @sellerID IS NULL 
	--	    --OR (c.[SellDate] >=@startDate and c.[SellDate] <=@endDate) OR @startDate = '' OR @startDate IS NULL OR @endDate = '' OR @endDate IS NULL
	--		group by SellDate,projectid,FishSellerId,FishSellId 

	--	END
	--if @isPartial = 1 AND (@startDate !='' AND @endDate !='' AND @projectId !='' AND @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate, [dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName
	--		,c.FishSellId
	--		from FishSellingReport c 
	--		WHERE (
	--			c.[SellDate] >=@startDate AND c.[SellDate] <=@endDate AND c.[ProjectId] =@projectId AND c.[FishSellerId] = @sellerID
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' AND @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[SellDate] <= @endDate
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] <= @endDate
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId !='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[ProjectId] = @projectId
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[FishSellerId] = @sellerID
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] <= @endDate
	--			AND
	--			c.[FishSellerId] = @sellerID
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END


	--	if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[FishSellerId] = @sellerID
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[SellDate] <= @endDate
	--			AND
	--			c.[FishSellerId] = @sellerID
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END
		
	--	if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId !='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] <= @endDate
	--			AND
	--			c.[ProjectId] = @projectId
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END




	--  if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId !='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[SellDate] <= @endDate
	--			AND
	--			c.[ProjectId] = @projectId
				
	--		) 

	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END


	--	if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			c.[SellDate] >= @startDate
	--			AND
	--			c.[SellDate] <= @endDate
	--			AND
	--			c.[FishSellerId] = @sellerID
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END


	--	if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			(c.[ProjectId] = @projectId )
	--			AND
	--			(c.[FishSellerId] = @sellerID)
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @sellerID ='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE c.[ProjectId] = @projectId
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END

	--	if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId ='' and @sellerID !='')

	--	BEGIN

	--		select CONVERT(VARCHAR(20),  c.SellDate) as SDate,[dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
	--		dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
	--		[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
	--		from FishSellingReport c

	--		WHERE (
	--			(c.[FishSellerId] = @sellerID)
				
	--		)
	--		group by SellDate,projectid,FishSellerId,FishSellId

	--	END


	if @isPartial = 0

		BEGIN

			select  CONVERT(VARCHAR(20),  c.SellDate) as SDate, [dbo].[uf_GetFishSellerNameByFishShellerId] (FishSellerId) as Name,projectid, convert(nvarchar(15),c.[SellDate],106) SellDate,FishSellerId, 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmount] (projectid,SellDate,FishSellerId)) as totalAmount, 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmount] (projectid,SellDate,FishSellerId)) as PaidAmount , 
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmount] (projectid,SellDate,FishSellerId)) as DueAmount,
			[dbo].[uf_GetProjectNameByProjectId]([ProjectId]) ProjectName,c.FishSellId
			from FishSellingReport c
			group by SellDate,projectid,FishSellerId,FishSellId

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingSellerReportForUserByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingSellerReportForUserByParam] 
( 
	@isPartial int=1,
	@sellerID int
) 

AS 
BEGIN 

	if @isPartial = 1 

		BEGIN
		select [dbo].[uf_GetFishSellerNameByFishShellerId] (c.FishSellerId) as Name, FishSellerId,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmountBySellerId] (c.FishSellerId)) as totalAmount,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmountBySellerId] (c.FishSellerId)) as PaidAmount,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmountBySellerId] (c.FishSellerId)) as DueAmount
			from FishSellingReport c 
			WHERE
			 (c.[FishSellerId] = @sellerID OR @sellerID = '' OR @sellerID IS NULL ) and c.IsClosedByAdmin=0
			group by c.FishSellerId

		END



	if @isPartial = 0

		BEGIN

			select [dbo].[uf_GetFishSellerNameByFishShellerId] (c.FishSellerId) as Name, FishSellerId,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerTotalAmountBySellerId] (c.FishSellerId)) as totalAmount,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerPaidAmountBySellerId] (c.FishSellerId)) as PaidAmount,
			dbo.uf_AddThousandSeparators([dbo].[uf_GetFishSellerDueAmountBySellerId] (c.FishSellerId)) as DueAmount
			from FishSellingReport c where c.IsClosedByAdmin=0
			group by FishSellerId

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingTotalAmountPaidAmountAndDueAmountBySellId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingTotalAmountPaidAmountAndDueAmountBySellId] 
( 
	@fishSellId int
) 

AS 
BEGIN 

	select
	SUM(TotalSellInKG) as TotalSellInKG,
	sum([FishAmountPaid]) as FishAmountPaid
	,SUM([FishAmountDue]) as FishAmountDue
	,SUM([TotalSellPrice]) as TotalSellPrice,
	dbo.uf_AddThousandSeparators(SUM(TotalSellInKG)) as TotalSellInKGString
	,dbo.uf_AddThousandSeparators(sum([FishAmountPaid])) as FishAmountPaidString
	,dbo.uf_AddThousandSeparators(SUM([FishAmountDue])) as FishAmountDueString
	,dbo.uf_AddThousandSeparators(SUM([TotalSellPrice])) as TotalSellPriceString
	from [dbo].[FishSellingReport]
	where [FishSellerId]=@fishSellId and IsClosedByAdmin=0
END






GO
/****** Object:  StoredProcedure [dbo].[up_GetFishSellingTotalForSellerID]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetFishSellingTotalForSellerID] 
( 
	@sellerId int
) 

AS 
BEGIN 

	select 
	dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.[TotalSellPrice]))) As TotalSellPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.[TotalSellInKG]))) As TotalSellInKG,
	dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellPrice])/SUM(c.[TotalSellInKG]))) As PricePerKg,
	CONVERT(VARCHAR(20),  c.SellDate,106) as SellDate,
	[dbo].[uf_GetFishSellerNameByFishId](c.FishSellerId) as SellerName,
	dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.[FishAmountPaid]))) As FishAmountPaid,
	dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.[FishAmountDue]))) As FishAmountDue
	 from [dbo].[FishSellingReport] c where c.[FishSellerId]= @sellerId group by c.[SellDate],c.[FishSellerId]

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetProjectListByAreaId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetProjectListByAreaId] 
( 
	
	@areaId int 
) 

AS 
BEGIN 

SELECT 
	f.ID, 
	f.Name
	from Project f 

	where 
	
	f.[AreaId] = @areaId 

	Order By f.ID ASC

END





GO
/****** Object:  StoredProcedure [dbo].[up_GetSegmentAreaListBySearch]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetSegmentAreaListBySearch] 
( 
	@searchText nvarchar(500), 
	@pageNumber int, 
	@pageSize int 
) 

AS 
BEGIN 

	SELECT 
	f.ID, 
	f.Name, 
	f.[Union_Name], 
	f.[WardNumber],
	f.ImageUrl, 
	convert(varchar(10),f.CreatedDate,103) CreaetdDate, 
	f.CreatedId 

	from Area f 

	where 
	( ( Convert(varchar(100),f.ID) = @searchText ) 

	OR ( (f.Name LIKE +'%'+ @searchText +'%' ) 
	OR (f.[Union_Name] LIKE +'%'+ @searchText ) 
	OR (f.[WardNumber] LIKE +'%'+ @searchText )
	OR (convert(varchar(10),f.CreatedDate,103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0


END





GO
/****** Object:  StoredProcedure [dbo].[up_GetSegmentFeedListBySearch]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetSegmentFeedListBySearch] 
( 
	@searchText nvarchar(500), 
	@pageNumber int, 
	@pageSize int 
) 

AS 
BEGIN 

	SELECT 
	f.ID, 
	f.Name, 
	[dbo].MyHTMLDecode([dbo].[udf_StripHTML](f.Description)) as Description, 
	f.ImageUrl, 
	convert(varchar(10),f.CreatedDate,103) CreaetdDate, 
	f.CreatedId 

	from Feed f 

	where 
	( ( Convert(varchar(100),f.ID) = @searchText ) 

	OR ( (f.Name LIKE +'%'+ @searchText +'%' ) 
	OR (f.Description LIKE +'%'+ @searchText +'%' ) 
	OR (convert(varchar(10),f.CreatedDate,103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0


END





GO
/****** Object:  StoredProcedure [dbo].[up_GetSegmentFishListBySearch]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetSegmentFishListBySearch] 
( 
	@searchText nvarchar(500), 
	@pageNumber int, 
	@pageSize int 
) 

AS 
BEGIN 

	SELECT 
	f.ID, 
	f.Name, 
	[dbo].MyHTMLDecode([dbo].[udf_StripHTML](f.Description)) as Description, 
	f.ImageUrl, 
	convert(varchar(10),f.CreatedDate,103) CreaetdDate, 
	f.CreatedId 

	from Fish f 

	where 
	( ( Convert(nvarchar(100),f.ID) = @searchText ) 

	OR ( (f.Name LIKE +'%'+ @searchText +'%' ) 
	OR (f.Description LIKE +'%'+ @searchText ) 
	OR (convert(nvarchar(10),f.CreatedDate,103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0



END





GO
/****** Object:  StoredProcedure [dbo].[up_GetSegmentProjectListBySearch]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetSegmentProjectListBySearch] 
( 
	@searchText nvarchar(500), 
	@pageNumber int, 
	@pageSize int 
) 

AS 
BEGIN 

	SELECT 
	f.ID, 
	f.Name, 
	f.[AreaId],
	f.ImageUrl, 
	f.[Time],
	f.[Land],
	dbo.uf_AddThousandSeparators(convert(nvarchar, f.[Cost])) AS Cost,
	convert(varchar(10),f.CreatedDate,103) CreaetdDate, 
	f.CreatedId 

	from Project f 

	where 
	( ( Convert(varchar(100),f.ID) = @searchText ) 

	OR ( (f.Name LIKE +'%'+ @searchText +'%' )  
	OR (convert(varchar(10),f.CreatedDate,103) LIKE @searchText +'%') ) )
	AND f.IsDeleted = 0
END





GO
/****** Object:  StoredProcedure [dbo].[up_GetSingleFishReportForPDF]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[up_GetSingleFishReportForPDF]
	(
		@sellId int
	)
AS
BEGIN
	

	SELECT
	f.[HisabName],
	f.[GarirName],
	f.[SellDate],
	f.FishSellId,
	convert(nvarchar(15),f.[SellDate],106) AS FishSellingDate,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[TotalSellInKG])) As TotalSellInKG,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[TotalSellPrice])) As TotalSellPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[FishAmountPaid])) As FishAmountPaid,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[FishAmountDue])) As FishAmountDue,
	[dbo].[uf_GetFishSellerNameByFishId](f.FishSellerId) SellerName
	FROM [dbo].[FishSellingReport] f where f.FishSellId=@sellId

END


GO
/****** Object:  StoredProcedure [dbo].[up_GetSingleFishReportOverview]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[up_GetSingleFishReportOverview]
	(
		@sellId int
	)
AS
BEGIN
	

	SELECT
	[dbo].[uf_GetFishNameByFishId](f.[SellFishId]) FishName,
	[dbo].[uf_GetFishSellerNameByFishShellerId](f.[FishSellerId]) FishSellerName,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[TotalFishkg])) As TotalFishkg,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[PricePerKG])) As PiecesPerKG,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),f.[TotalSellPrice])) As TotalSellPrice

	from [dbo].[FishSellingReportMapper] f where f.FishSellReportId=@sellId

END


GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFeedBillingReportByFeedId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFeedBillingReportByFeedId] 
( 
	@feedId varchar (10)
) 

AS 
BEGIN 

	IF @feedId !=''
		
		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalPrice]))) TOTALPriceString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedTotalBags]))) FeedTotalBagsString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedBagsWeight]))) FeedBagsWeightString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalWeight]))) TotalWeightString,
			sum(mp.[TotalPrice]) TOTALPrice,
			sum(mp.[FeedTotalBags]) FeedTotalBags,
			sum(mp.[FeedBagsWeight]) FeedBagsWeight,
			sum(mp.[TotalWeight]) TotalWeight

			FROM
			[dbo].[FeedSellingReport] f
			Inner join [dbo].[FeedSellingReportMapper] mp on mp.[FeedSellingReportId]=f.[FeedSellingReportId]
			where mp.[FeedId]=@feedId
			group by mp.[FeedId]

		END
	ELSE

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalPrice]))) TOTALPriceString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedTotalBags]))) FeedTotalBagsString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[FeedBagsWeight]))) FeedBagsWeightString,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(mp.[TotalWeight]))) TotalWeightString,
			sum(mp.[TotalPrice]) TOTALPrice,
			sum(mp.[FeedTotalBags]) FeedTotalBags,
			sum(mp.[FeedBagsWeight]) FeedBagsWeight,
			sum(mp.[TotalWeight]) TotalWeight

			FROM
			[dbo].[FeedSellingReport] f
			Inner join [dbo].[FeedSellingReportMapper] mp on mp.[FeedSellingReportId]=f.[FeedSellingReportId]
			--group by mp.[FeedId]
		END


END



GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFeedPurchaseReportByAreaId]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFeedPurchaseReportByAreaId] 
( 
	@areaId varchar (10)
) 

AS 
BEGIN 


	DECLARE @TotalTempTable TABLE(TotalWeight decimal(18,0),TotalPrice decimal(18,0))
		INSERT INTO @TotalTempTable
			SELECT
			 mp.TotalWeight,
			mp.TotalPrice

	FROM [dbo].[FeedSellingReport] c

	left outer JOIN [dbo].[FeedSellingReportMapper] mp ON mp.[FeedSellingReportId] = c.[FeedSellingReportId]
	WHERE (mp.[MapperAreaId] LIKE '%' + @areaId + '%'  OR  mp.[MapperAreaId] LIKE '%'+ @areaId OR  mp.[MapperAreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)


	SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.TotalWeight))) As TotalWeight,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.TotalPrice))) As TotalPrice

	FROM @TotalTempTable c



END



GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFeedPurchaseReportBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFeedPurchaseReportBySearchParam] 
( 
	@feedId varchar (10),
	@catId varchar (10),
	@areaId varchar (10),
	@projectId varchar (10),
	@calculationName nvarchar(max)
) 

AS 
BEGIN 


	--if @isPartial = 1
		--BEGIN
		DECLARE @TotalTempTable TABLE(SellingFeedTotalWeight decimal(18,0),SellingFeedTotalPrice decimal(18,0),FeedAmountPaid decimal(18,0),FeedAmountDue decimal(18,0))
		INSERT INTO @TotalTempTable
			SELECT
			 c.SellingFeedTotalWeight,
			c.SellingFeedTotalPrice,
			c.FeedAmountPaid,
			c.FeedAmountDue

	FROM [dbo].[FeedSellingReport] c

	left outer JOIN [dbo].[FeedSellingReportMapper] mp ON mp.[FeedSellingReportId] = c.[FeedSellingReportId]
	WHERE 
	 (mp.[MapperAreaId] LIKE '%' + @areaId + '%'  OR  mp.[MapperAreaId] LIKE '%'+ @areaId OR  mp.[MapperAreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)

	group by c.SellingFeedTotalWeight,c.SellingFeedTotalPrice,c.FeedAmountPaid,c.FeedAmountDue

	SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.SellingFeedTotalWeight))) As SellingFeedTotalWeight,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.SellingFeedTotalPrice))) As SellingFeedTotalPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.FeedAmountPaid))) As FeedAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), sum(c.FeedAmountDue))) As FeedAmountDue

	FROM @TotalTempTable c


	
		--(convert(nvarchar(10), c.[SellingFeedCalculationDate],103) = COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(10), c.[SellingFeedCalculationDate],103))
		--	OR
		--	convert(nvarchar(15), c.[SellingFeedCalculationDate],106) like +'%'+  COALESCE(NULLIF(@calCulationName, ''), convert(nvarchar(15), c.[SellingFeedCalculationDate],106))+'%'
		--	OR
		--	c.[SellingFeedReportNumber] like +'%'+ COALESCE(NULLIF(@calculationName, ''), c.[SellingFeedReportNumber]) +'%'
		--	or
		--	c.[SellingReportName] like +'%'+ COALESCE(NULLIF(@calculationName, ''), c.[SellingReportName]) +'%')
		--	and
		--(
		--	mp.[FeedId] = COALESCE(NULLIF(@feedId, ''), mp.[FeedId])
		--	and
		--	mp.[FeedCategoryId] = COALESCE(NULLIF(@catId, ''), mp.[FeedCategoryId])
		--	and
		--	c.[AreaId] = COALESCE(NULLIF(@areaId, ''), c.[AreaId])
		--	and
		--	c.[ProjectId] = COALESCE(NULLIF(@projectId, ''), c.[ProjectId])
		--)


		--END


		--if @isPartial = 0

		--	BEGIN

		--	SELECT
		--	dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.SellingFeedTotalWeight))) As SellingFeedTotalWeight,
		--	dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.SellingFeedTotalPrice))) As SellingFeedTotalPrice,
		--	dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.FeedAmountPaid))) As FeedAmountPaid,
		--	dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.FeedAmountDue))) As FeedAmountDue

		--	FROM [dbo].[FeedSellingReport] c
		--	INNER JOIN [dbo].[FeedSellingReportMapper] mp ON mp.[FeedSellingReportId] = c.[FeedSellingReportId]


		--END

END



GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFeedPurchaseSingleReport]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFeedPurchaseSingleReport] 
( 
	@reportId int
) 

AS 
BEGIN 

	select	
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),sum(mp.[FeedTotalBags]))) As FeedTotalBags,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),sum(mp.[FeedBagsWeight]))) As FeedBagsWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),sum(mp.[TotalWeight]))) As TotalWeight,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),sum(mp.[TotalPrice]))) As TotalPrice,
	dbo.uf_AddThousandSeparators(convert(nvarchar(100),sum(mp.[PricePerKg]))) As PricePerKg
		
	from 
	[dbo].[FeedSellingReportMapper] mp
	where mp.FeedSellingReportId=@reportId

END



GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFishSellingReportByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFishSellingReportByParam] 
( 
	@areaId varchar (10),
	@projectId varchar (10),
	@calCulationName varchar (10),
	@isPartial int=1
) 

AS 
BEGIN 

	if @isPartial = 1

		BEGIN
			SELECT 
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TOTAL_SELL_IN_KG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice])/SUM(c.[TotalSellInKG]))) PricePerKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) As FishAmountDue,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) As FishAmountPaid
			FROM [dbo].[FishSellingReport] c

			WHERE 
				IsClosedByAdmin = 0
				 and (c.[AreaId] LIKE '%' + @areaId + '%'  OR  c.[AreaId] LIKE '%'+ @areaId OR  c.[AreaId] LIKE @areaId + '%' OR @areaId = '' OR @areaId IS NULL)
				 and (c.[ProjectId] LIKE '%' + @projectId + '%'  OR  c.[ProjectId] LIKE '%'+ @projectId OR  c.[ProjectId] LIKE @projectId + '%' OR @projectId = '' OR @projectId IS NULL)
				and (c.[FishSellerId] LIKE '%' + @calCulationName + '%'  OR  c.[FishSellerId] LIKE '%'+ @calCulationName OR  c.[FishSellerId] LIKE @calCulationName + '%' OR @calCulationName = '' OR @calCulationName IS NULL)
					
				
		END


	if @isPartial = 0

		BEGIN

			SELECT 
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TOTAL_SELL_IN_KG,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice])/SUM(c.[TotalSellInKG]))) PricePerKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) As FishAmountDue,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) As FishAmountPaid
			FROM [dbo].[FishSellingReport] c
			
			where
			 IsClosedByAdmin = 0

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFishSellingReportForAdminByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFishSellingReportForAdminByParam] 
( 
	@startDate date,
	@endDate Date,
	@isPartial int=1,
	@areaId int,
	@projectId int
) 

AS 
BEGIN 

	if @isPartial = 1 AND (@startDate !='' AND @endDate !='' AND @projectId !='' AND @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >=@startDate AND c.[SellDate] <=@endDate AND c.[ProjectId] =@projectId AND c.[AreaId]=@areaId
			)

		END

	if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' AND @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				
			)

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[ProjectId] = @projectId
				
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[AreaId]=@areaId
			)
		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
			)

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[AreaId]=@areaId
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
			)

		END
		
		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
			)

		END




	  if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
				
			)

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[AreaId]=@areaId
				
			)

		END


		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[ProjectId] = @projectId )
				AND
				(c.[AreaId]=@areaId)
				
			)

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @areaId ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE c.[ProjectId] = @projectId

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId ='' and @areaId !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[AreaId]=@areaId)
				
			)

		END


	if @isPartial = 0

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c


		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFishSellingSellerReportForAdminByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFishSellingSellerReportForAdminByParam] 
( 
	@startDate date,
	@endDate Date,
	@isPartial int=1,
	@projectId int,
	@sellerID int
) 

AS 
BEGIN 

	if @isPartial = 1 AND (@startDate !='' AND @endDate !='' AND @projectId !='' AND @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c
			WHERE (
				c.[SellDate] >=@startDate AND c.[SellDate] <=@endDate AND c.[ProjectId] =@projectId AND c.[FishSellerId] = @sellerID
			)

		END

	if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' AND @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				
			)

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId !='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[ProjectId] = @projectId
				
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[FishSellerId] = @sellerID
			)

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[FishSellerId] = @sellerID
			)

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate ='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[FishSellerId] = @sellerID
			)

		END

		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[FishSellerId] = @sellerID
			)

		END
		
		if (@isPartial = 1 and  @startDate ='' and @endDate !='' and @projectId !='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
			)

		END




	  if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId !='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[ProjectId] = @projectId
				
			) 

		END


		if (@isPartial = 1 and  @startDate !='' and @endDate !='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				c.[SellDate] >= @startDate
				AND
				c.[SellDate] <= @endDate
				AND
				c.[FishSellerId] = @sellerID
				
			)

		END


		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[ProjectId] = @projectId )
				AND
				(c.[FishSellerId] = @sellerID)
				
			)

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId !='' and @sellerID ='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE c.[ProjectId] = @projectId

		END

		if (@isPartial = 1 and  @startDate ='' and @endDate ='' and @projectId ='' and @sellerID !='')

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

			WHERE (
				(c.[FishSellerId] = @sellerID)
				
			)

		END


	if @isPartial = 0

		BEGIN

			SELECT
			dbo.uf_AddThousandSeparators(convert(nvarchar(500), SUM(c.[TotalSellInKG]))) As TotalSellInKg,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[TotalSellPrice]))) As TotalSellPrice,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountPaid]))) FishAmountPaid,
			dbo.uf_AddThousandSeparators(convert(nvarchar(500),SUM(c.[FishAmountDue]))) FishAmountDue
			FROM [dbo].[FishSellingReport] c

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetTotalFishSellingSellerReportForUserByParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetTotalFishSellingSellerReportForUserByParam] 
( 
	@isPartial int=1,
	@sellerID int
) 

AS 
BEGIN 

	if @isPartial = 1 

		BEGIN
		select 
			dbo.uf_AddThousandSeparators(SUM([TotalSellPrice])) as totalAmountString,
			dbo.uf_AddThousandSeparators(sum([FishAmountPaid])) as PaidAmountString,
			dbo.uf_AddThousandSeparators(SUM([FishAmountDue])) as DueAmountString,
			SUM([TotalSellPrice]) as totalAmount,
			sum([FishAmountPaid]) as PaidAmount,
			SUM([FishAmountDue]) as DueAmount
			from FishSellingReport c 
			WHERE
			 (c.[FishSellerId] = @sellerID OR @sellerID = '' OR @sellerID IS NULL ) and c.IsClosedByAdmin=0

		END



	if @isPartial = 0

		BEGIN

			select 
			dbo.uf_AddThousandSeparators(SUM([TotalSellPrice])) as totalAmountString,
			dbo.uf_AddThousandSeparators(sum([FishAmountPaid])) as PaidAmountString,
			dbo.uf_AddThousandSeparators(SUM([FishAmountDue])) as DueAmountString,
			SUM([TotalSellPrice]) as totalAmount,
			sum([FishAmountPaid]) as PaidAmount,
			SUM([FishAmountDue]) as DueAmount
			from FishSellingReport c  where c.IsClosedByAdmin=0
			--group by FishSellerId

		END

END






GO
/****** Object:  StoredProcedure [dbo].[up_GetTrashDataByTableID]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[up_GetTrashDataByTableID](
	@tableID int,
	@isAllData int
)
AS
BEGIN

	DECLARE @TrashDataTable TABLE
	(
		RowId int NOT NULL identity(1,1),
		ID int, 
		Name nvarchar(max),
		ImageUrl nvarchar(max),
		TableName nvarchar(max),
		TableID int,
		CreatedDate nvarchar(13)
	)

	if @isAllData = 0

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Fish', 1, convert(varchar(10),CreatedDate,103)
			FROM [Fish] where isDeleted=1;


			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Feed', 2, convert(varchar(10),CreatedDate,103)
			FROM [Feed] where isDeleted=1;

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT FeedCategoryId, FeedCategoryName, FeedCategoryImageUrl, 'FeedCategories', 3, convert(varchar(10),CreatedDate,103)
			FROM [FeedCategories] where isDeleted=1;

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Area', 4, convert(varchar(10),CreatedDate,103)
			FROM [Area] where isDeleted=1;

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Project', 5, convert(varchar(10),CreatedDate,103)
			FROM [Project] where isDeleted=1;

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'FishSeller', 6, convert(varchar(10),CreatedDate,103)
			FROM [FishSeller] where isDeleted=1;

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Expend', 7, convert(varchar(10),CreatedDate,103)
			FROM [Expend] where isDeleted=1;

			select * from @TrashDataTable t

			order by RowId

		END

	if @isAllData = 1 and @tableID = 1

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Fish', 1, convert(varchar(10),CreatedDate,103)
			FROM [Fish] where isDeleted=1;

			select * from @TrashDataTable t
			order by RowId

		END

	if @isAllData = 1 and @tableID = 2

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Feed', 2, convert(varchar(10),CreatedDate,103)
			FROM [Feed] where isDeleted=1;

			select * from @TrashDataTable t
			order by RowId
		END

	if @isAllData = 1 and @tableID = 3

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT FeedCategoryId, FeedCategoryName, FeedCategoryImageUrl, 'FeedCategories', 3, convert(varchar(10),CreatedDate,103)
			FROM [FeedCategories] where isDeleted=1;
			
			select * from @TrashDataTable t
			order by RowId
		END

	if @isAllData = 1 and @tableID = 4

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Area', 4, convert(varchar(10),CreatedDate,103)
			FROM [Area] where isDeleted=1;
			
			select * from @TrashDataTable t
			order by RowId
		END

	if @isAllData = 1 and @tableID = 5

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Project', 5, convert(varchar(10),CreatedDate,103)
			FROM [Project] where isDeleted=1;
			
			select * from @TrashDataTable t
			order by RowId
		END

	if @isAllData = 1 and @tableID = 6

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'FishSeller', 6, convert(varchar(10),CreatedDate,103)
			FROM [FishSeller] where isDeleted=1;
			
			select * from @TrashDataTable t
			order by RowId
		END

	if @isAllData = 1 and @tableID = 7

		BEGIN

			INSERT INTO @TrashDataTable (ID, Name,ImageUrl,TableName, TableID, CreatedDate)
			SELECT ID, Name, ImageUrl, 'Expend', 6, convert(varchar(10),CreatedDate,103)
			FROM [Expend] where isDeleted=1;
			
			select * from @TrashDataTable t
			order by RowId
		END

END




GO
/****** Object:  StoredProcedure [dbo].[up_GetUserListBySearchParam]    Script Date: 7/14/2019 12:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_GetUserListBySearchParam] 
( 
	@searchText nvarchar(500)
) 

AS 
BEGIN 

	SELECT 
	u.[UserID], 
	u.[FirstName],
	u.[FirstName] + ' ' + u.[LastName] as UserFullName, 
	u.[PhoneNumber],
	u.[UserImagePath],
	[dbo].[uf_GetUserProjectNameByAreaIdAndProjectId] (u.[AreaID],u.[ProjectID]) AS ProjectDetails

	from [dbo].[Users] u

	where 
		( ( Convert(nvarchar(100),u.[UserID]) = @searchText )
		OR (u.[FirstName] LIKE +'%'+ @searchText +'%' )
		OR (u.[LastName] LIKE +'%'+ @searchText +'%' ))

END





GO
