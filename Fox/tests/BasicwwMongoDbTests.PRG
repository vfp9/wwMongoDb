
DEFINE CLASS BasicwwMongoDbTests as FxuTestCase OF FxuTestCase.prg


*** SETUP AND CONFIGURATION *** 

************************************************************************
*  Setup
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION Setup()

	*** Make sure libraries are loaded
	DO wwMongoDb

ENDFUNC
*   Setup

************************************************************************
*  TearDown
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION TearDown()

ENDFUNC
*   TearDown

************************************************************************
*  CreateMongo
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CreateMongo()

loMongo = CREATEOBJECT("wwMongoDb")
loMongo.Connect("mongodb://localhost/FoxMongoTest")

RETURN loMongo
ENDFUNC
*   CreateMongo

*** END SETUP AND CONFIGURATION ***



*** TESTS ***


************************************************************************
*   ConnectionTest
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ConnectionTest()

*** Explicitly create an instance and connect
loMongo = CREATEOBJECT("wwMongoDb")
this.AssertTrue(loMongo.Connect("mongodb://localhost/FoxMongoTest"),loMongo.cErrorMsg)

ENDFUNC
*  ConnectionTest

************************************************************************
*  SaveEntityWithChildren
****************************************
FUNCTION SaveEntityWithChildrenWithTest()

loMongo = this.CreateMongo()

*** Note objects are serialized as lower case
loCustomer = CREATEOBJECT("EMPTY")

*** Recommend you assign your own ids for easier querying
ADDPROPERTY(loCustomer,"_id",SYS(2015))
ADDPROPERTY(loCustomer,"FirstName","Markus")
ADDPROPERTY(loCustomer,"LastName","Egger")
ADDPROPERTY(loCustomer,"Company","EPS Software")
ADDPROPERTY(loCustomer,"Entered", DATETIME())

loAddress = CREATEOBJECT("EMPTY")
ADDPROPERTY(loAddress,"Street","34 Kaiea")
ADDPROPERTY(loAddress,"City","Paia")
ADDPROPERTY(loCustomer,"Address",loAddress)

loOrders = CREATEOBJECT("Collection")
ADDPROPERTY(loCustomer,"Orders",loOrders)

loOrder = CREATEOBJECT("Empty")
ADDPROPERTY(loOrder,"Date",DATETIME())
ADDPROPERTY(loOrder,"OrderId",SUBSTR(SYS(2015),2))
ADDPROPERTY(loOrder,"OrderTotal",120.00)
loOrders.Add(loOrder)

loOrder = CREATEOBJECT("Empty")
ADDPROPERTY(loOrder,"Date",DATETIME())
ADDPROPERTY(loOrder,"OrderId",SUBSTR(SYS(2015),2))
ADDPROPERTY(loOrder,"OrderTotal",120.00)
loOrders.Add(loOrder)

this.AssertTrue(loMongo.Save(loCustomer,"Customers"),loMongo.cErrorMsg)

this.AssertTrue(loCustomer._id == loMongo.oLastResult.Id,"Own id shouldn't be updated")

this.MessageOut("ID Generated: " + loMongo.oLastResult.Id)

ENDFUNC
*  SaveEntityWithChildrenWithTest

************************************************************************
*  SaveEntityFromJson
****************************************
FUNCTION SaveEntityFromJson()

loMongo = this.CreateMongo()

*** Note objects are serialized as lower case
loCustomer = CREATEOBJECT("EMPTY")

TEXT TO lcJson TEXTMERGE NOSHOW
{
    _id: "<<loMongo.GenerateId()>>",
    FirstName: "Rick",
    LastName: "Strahl",
    Company: "West Wind",
    Entered: "<<TTOC(DATETIME(),3)>>",
    Address: {
        Street: "32 Kaiea",
        City: "Paia"
    },
    Orders: [
        { OrderId: "ar431211", OrderTotal: 125.44, Date: "<<TTOC(DATETIME(),3)>>Z"},
        { OrderId: "fe134341", OrderTotal: 95.12, Date: "<<TTOC(DATETIME(),3)>>Z" }
    ]
}
ENDTEXT

this.AssertTrue(loMongo.Save(lcJson,"Customers",.T.),loMongo.cErrorMsg)

*** Another way to check for errors
this.AssertTrue(loMongo.oLastResult.Ok,loMongo.oLastResult.Message)

lcId = loMongo.oLastResult.Id
this.MessageOut("ID Generated: " + lcId)

loCustomer = loMongo.Load(lcId,"Customers")

this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
               " (" + TRANSFORM(loCustomer.entered) + ")" + ;
               " (ID: " + TRANSFORM(loCustomer._id) + ")")


ENDFUNC
*  SaveEntityWithChildrenWithTest


************************************************************************
*  SaveManyEntities
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION SaveManyEntities()

loMongo = this.CreateMongo()

FOR lnx = 1 TO 10000

	*** Note objects are serialized as lower case
	loCustomer = CREATEOBJECT("EMPTY")

	TEXT TO lcJson TEXTMERGE NOSHOW
{
    _id: "<<loMongo.GenerateId()>>",
    FirstName: "Rick",
    LastName: "Strahl",
    Company: "East Wind",
    Entered: "<<TTOC(DATETIME(),3)>>",
    Address: {
        Street: "32 Kaiea",
        City: "Paia"
    },
    Orders: [
        { OrderId: "ar431211", OrderTotal: 125.44, Date: "<<TTOC(DATETIME(),3)>>Z"},
        { OrderId: "fe134341", OrderTotal: 95.12, Date: "<<TTOC(DATETIME(),3)>>Z" }
    ]
}
	ENDTEXT

	loMongo.Save(lcJson,"Customers")
ENDFOR

this.AssertTrue(loMongo.Save(lcJson,"Customers",.T.),loMongo.cErrorMsg)

*** Another way to check for errors
this.AssertTrue(loMongo.oLastResult.Ok,loMongo.oLastResult.Message)

lcId = loMongo.oLastResult.Id
this.MessageOut("ID Generated: " + lcId)

loCustomer = loMongo.Load(lcId,"Customers")

this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
               " (" + TRANSFORM(loCustomer.entered) + ")" + ;
               " (ID: " + TRANSFORM(loCustomer._id) + ")")


ENDFUNC
*   SaveManyEntities




************************************************************************
*  BasicSaveEntityTest
****************************************
FUNCTION BasicSaveEntityTest()

*** Create instance (reused in all tests)
loMongo = this.CreateMongo()

*** Note objects are serialized as lower case
loCustomer = CREATEOBJECT("EMPTY")

*** Highly recommend you create your own ids - so that they 
*** are stored as strings or numbers rather than object IDs
ADDPROPERTY(loCustomer,"_id",loMongo.GenerateId())
ADDPROPERTY(loCustomer,"FirstName","Rick")
ADDPROPERTY(loCustomer,"LastName","Strahl")
ADDPROPERTY(loCustomer,"Company","West Wind Technologies")
ADDPROPERTY(loCustomer,"Entered",DATETIME())
ADDPROPERTY(loCustomer,"Orders",CREATEOBJECT("Collection"))

loAddress = CREATEOBJECT("EMPTY")
ADDPROPERTY(loAddress,"Street","32 Kaiea")
ADDPROPERTY(loAddress,"City","Paia")

ADDPROPERTY(loCustomer,"Address",loAddress)

this.AssertTrue(loMongo.Save(loCustomer,"Customers"),loMongo.cErrorMsg)

this.MessageOut("ID Generated: " + loMongo.oLastResult.Id)

ENDFUNC
*  BasicSaveEntityTest

************************************************************************
*  FindTest
****************************************
***  Function: Finds a list of records that match the search
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION FindTest()
LOCAL loMongo

loMongo = this.CreateMongo()
loCustomers = loMongo.Find('{ firstname: "Rick" }',"Customers",0,100)  && skip 0 limit 100

this.AssertNotNull(loCustomers,"Customers shouldn't be null")

FOR lnX = 1 TO loCustomers.Count
   loCustomer = loCustomers[lnX]
   *** NOTE: MongoDb dates come back as objects so use GetDate()
   this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
                " (" + TRANSFORM(loMongo.GetDate(loCustomer.entered)) + ")" + ;
                " (ID: " + TRANSFORM(loCustomer._id) + ")")  && top 5
ENDFOR

ENDFUNC
*   FindTest

************************************************************************
*  Find2Test
****************************************
***  Function: Finds a list of records that match the search
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION FindMoreComplexTest()
LOCAL loMongo

loMongo = this.CreateMongo()
*firstname: /^R.*/i,
loCustomers = loMongo.Find('{ firstname: /^R.*/i,  entered: { "$gte": new Date(2011,11,1) } }',;
						  "Customers",0,100 )  && skip 0, limit 100

this.AssertNotNull(loCustomers,"Customers shouldnt be null")

this.MessageOut("Count: " + TRANSFORM(loCustomers.Count))

FOR lnX = 1 TO loCustomers.Count
   loCustomer = loCustomers[lnX]
   *** NOTE: MongoDb dates come back as objects so use GetDate()
   this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
                " (" + TRANSFORM(loMongo.GetDate(loCustomer.entered)) + ")" + ;
                " (ID: " + TRANSFORM(loCustomer._id) + ")")

ENDFOR

ENDFUNC
*   FindTest

*!*	************************************************************************
*!*	*  FindTest
*!*	****************************************
*!*	***  Function: Finds a list of records that match the search
*!*	***    Assume:
*!*	***      Pass:
*!*	***    Return:
*!*	************************************************************************
*!*	FUNCTION FindWithObjectTest()

*!*	loMongo = this.CreateMongo()


*!*	loQuery = CREATEOBJECT("EMPTY")
*!*	ADDPROPERTY(loQuery,"firstname","Rick (Fox)")

*!*	loDate= CREATEOBJECT("EMPTY")
*!*	ADDPROPERTY(loDate,"___gte",{1-1-2014})
*!*	ADDPROPERTY(loQuery,"entered",loDate)

*!*	loCustomers = loMongo.Find(loDate,"Customers")

*!*	this.AssertNotNull(loCustomers,"Customers shouldnt be null")

*!*	FOR lnX = 1 TO loCustomers.Count
*!*	   loCustomer = loCustomers[lnX]
*!*	   this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + " (" + TRANSFORM(loCustomer.Entered) + ")" + " (" + TRANSFORM(loCustomer._id) + ")" )
*!*	ENDFOR

*!*	ENDFUNC
*!*	*   FindTest

************************************************************************
*  FindOneTest
****************************************
***  Function: Finds the first record that matches the search
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION FindOneTest()

loMongo = this.CreateMongo()

loCustomer = loMongo.FindOne('{ firstname: "Rick" }',"Customers")

this.AssertNotNull(loCustomer,"Customers shouldnt be null")

*** NOTE: MongoDb dates come back as objects so use GetDate()
this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
                " (" + TRANSFORM(loMongo.GetDate(loCustomer.entered)) + ")" + ;
                " (ID: " + TRANSFORM(loCustomer._id) + ")")

*** Child Object
IF !ISNULL(loCustomer.Address)
   this.MessageOut( "   " + loCustomer.Address.Street + ", " + loCustomer.Address.City )
ENDIF

*** Child Collection                
IF !ISNULL(loCustomer.Orders)     
    FOR lnx=1 TO loCustomer.Orders.Count   
		loOrder = loCustomer.Orders[lnX]
	    this.MessageOut( "    " + TRANSFORM(loMongo.GetDate(loOrder.Date))  + "  " + ;
	    				 loOrder.OrderId + " " + TRANSFORM(loOrder.OrderTotal) )
	ENDFOR        
ENDIF                

ENDFUNC
*   FindOneTest

************************************************************************
*  FindOneTest
****************************************
***  Function: Finds the first record that matches the search
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION LoadTest()

loMongo = this.CreateMongo()

*** Retrieve an id
loCustomer = loMongo.FindOne('{ firstname: "Rick" }',"Customers")
this.AssertNotNull(loCustomer,"Before id retrieval failed")
lcId = loCustomer._id
this.MessageOut("ID to search for: " + lcId)

loCustomer = loMongo.Load(lcId,"Customers")

this.AssertNotNull(loCustomer,"Customers shouldnt be null")

this.MessageOut( loCustomer.FirstName + " " + loCustomer.LastName + ;
                " (" + TRANSFORM(loMongo.GetDate(loCustomer.entered)) + ")" + ;
                " (ID: " + TRANSFORM(loCustomer._id) + ")")


*** Child Object
IF !ISNULL(loCustomer.Address)
   this.MessageOut( "   " + loCustomer.Address.Street + ", " + loCustomer.Address.City )
ENDIF

*** Child Collection                
IF !ISNULL(loCustomer.Orders)     
    FOR lnx=1 TO loCustomer.Orders.Count   
		loOrder = loCustomer.Orders[lnX]
	    this.MessageOut( "    " + TRANSFORM(loMongo.GetDate(loOrder.Date))  + "  " + ;
	    				 loOrder.OrderId + " " + TRANSFORM(loOrder.OrderTotal) )
	ENDFOR        
ENDIF                                

ENDFUNC
*   FindTest

************************************************************************
*  Aggregate
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION AggregateTest()

loMongo = this.CreateMongo()

TEXT TO lcJson NOSHOW
[    
       { $project: { Company: "$Company", OrderCount: { $size: "$Orders" }} },       
       { $match: {                   
              Company: {$gte: "C" },
              OrderCount: { $gt: 0 }
           }
      },

      { $group: {         
          _id: "$Company", 
          CustomerCount: {$sum: 1 } ,
          OrderCount: {$sum: "$OrderCount" }
        }          
     }
]
ENDTEXT

loResults = loMongo.Aggregate(lcJson,"Customers")
this.AssertNotNull(loResults,loMongo.cErrorMsg)

lnCount = loResults.Count
this.MessageOut(TRANSFORM(lnCount) + " results")
FOR lnX = 1 TO lnCount
   loResult = loResults[lnX]
   this.MessageOut( TRANSFORM(loResult._id) + ;
                    "  Cust Count: " + TRANSFORM(loResult.CustomerCount) + ;
                    "  Order Count: " + TRANSFORM(loResult.OrderCount) )
ENDFOR

ENDFUNC
*   Aggregate


************************************************************************
*  DeleteOneTest
****************************************
***  Function: Deletes an entity by ID
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION DeleteOneTest()

loMongo = this.CreateMongo()

*** Retrieve an id
loCustomer = loMongo.FindOne('{ firstname: "Rick" }',"Customers")
this.AssertNotNull(loCustomer,"Before id retrieval failed")
lcId = loCustomer._id
this.MessageOut("ID to search for: " + lcId)
loCustomer = null

llResult = loMongo.Delete(lcId,"Customers")

this.AssertTrue(llResult,"Customer not deleted: " + loMongo.cErrorMsg)
this.MessageOut("Documents deleted: " + TRANSFORM(loMongo.oLastResult.DocumentsAffected))

ENDFUNC
*   DeleteOne


************************************************************************
*  DeleteWithFilterTest
****************************************
***  Function: Deletes multiple entities based on a filter expression
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION DeleteWithFilterTest()

loMongo = this.CreateMongo()

llResult = loMongo.Delete('{ firstname: "Markus" }',"Customers")

this.AssertTrue(llResult,"Customer not deleted: " + loMongo.cErrorMsg)
this.MessageOut("Documents deleted: " + TRANSFORM(loMongo.oLastResult.DocumentsAffected))

ENDFUNC
*   DeleteOne

************************************************************************
*  AccessCollection
****************************************
***  Function: Example of directly accessing the .NET MongoDb collection
***            object.
***    Assume:
***      Pass: 
***    Return:
************************************************************************
FUNCTION AccessCollection()

loMongo = this.CreateMongo()

loCollection = loMongo.GetCollection("Customers")

this.AssertTrue(VARTYPE(loCollection) = "O","Collection retrieval failed")

*** loCollection is a generic object so you can't directly
*** access any methods. Use InvokeMethod() or Get/SetProperty()
*** for all member access.
lnRecordCount = loMongo.oBridge.InvokeMethod(loCollection,"count")

*** Some other things you can do:
* loMongo.oBridge.InvokeMethod(loCollection,"removeAll")
* loMongo.oBridge.InvokeMethod(loCollection,"drop")
* loMongo.oBridge.InvokeMethod(loCollection,"validate")
* 

this.MessageOut("Record count: " + TRANSFORM(lnRecordCount) )
ENDFUNC
*   AccessCollection


*** The following tests are commented in order to not 
*** force too many records into the DB for tests
*** Selectively disable these.

*!*	************************************************************************
*!*	*  RunManyInserts
*!*	****************************************
*!*	FUNCTION RunManyInserts()

*!*	loMongo = this.CreateMongo()

*!*	*** Note objects are serialized as lower case
*!*	loCustomer = CREATEOBJECT("EMPTY")

*!*	*** Recommend you assign your own ids for easier querying
*!*	ADDPROPERTY(loCustomer,"_id",SYS(2015))
*!*	ADDPROPERTY(loCustomer,"FirstName","Rick")
*!*	ADDPROPERTY(loCustomer,"LastName","Strahl")
*!*	ADDPROPERTY(loCustomer,"Company","West Wind")
*!*	ADDPROPERTY(loCustomer,"Entered", DATETIME())

*!*	loAddress = CREATEOBJECT("EMPTY")
*!*	ADDPROPERTY(loAddress,"Street","32 Kaiea")
*!*	ADDPROPERTY(loAddress,"City","Paia")
*!*	ADDPROPERTY(loCustomer,"Address",loAddress)

*!*	loOrders = CREATEOBJECT("Collection")
*!*	ADDPROPERTY(loCustomer,"Orders",loOrders)

*!*	loOrder = CREATEOBJECT("Empty")
*!*	ADDPROPERTY(loOrder,"Date",DATETIME())
*!*	ADDPROPERTY(loOrder,"OrderId",SUBSTR(SYS(2015),2))
*!*	ADDPROPERTY(loOrder,"OrderTotal",121.10)
*!*	loOrders.Add(loOrder)

*!*	loOrder = CREATEOBJECT("Empty")
*!*	ADDPROPERTY(loOrder,"Date",DATETIME())
*!*	ADDPROPERTY(loOrder,"OrderId",SUBSTR(SYS(2015),2))
*!*	ADDPROPERTY(loOrder,"OrderTotal",44.22)
*!*	loOrders.Add(loOrder)


*!*	lnCount = 10000
*!*	lnStart = SECONDS()
*!*	FOR lnX = 1 TO lnCount
*!*		loCustomer._id = SYS(2015)
*!*		loMongo.Save(loCustomer,"Customers")
*!*	ENDFOR

*!*	this.MessageOut(TRANSFORM(lnCount) + " messages inserted in " + TRANSFORM(SECONDS() - lnStart))

*!*	ENDFUNC
*!*	*  RunManyInserts



*!*	************************************************************************
*!*	*  RunManyInsertsWithJson
*!*	**************************
*!*	*  Notes:
*!*	*  This version is considerably faster than the previous test 
*!*	*  as there's no JSON conversion from Fox object to JSON.
*!*	*
*!*	*  The performance variance is large, but be aware that 
*!*	*  you have to be careful creating JSON as text because
*!*	*  Json values do need encoding: Dates, strings (extended,
*!*	*  quotes, special JS characters etc.) which complicates
*!*	*  just sticking expression into a TEXTMERGE variable.
*!*	*  Your mileage may vary.
*!*	************************************************************************
*!*	FUNCTION RunManyInsertsWithJson()

*!*	loMongo = this.CreateMongo()

*!*	*** Note objects are serialized as lower case
*!*	loCustomer = CREATEOBJECT("EMPTY")

*!*	lnCount = 10000
*!*	lnStart = SECONDS()
*!*	FOR lnX = 1 TO lnCount
*!*	TEXT TO lcJson TEXTMERGE NOSHOW
*!*		{
*!*		    _id: "<<loMongo.GenerateId()>>",
*!*		    FirstName: "Rick",
*!*		    LastName: "Strahl",
*!*		    Company: "West Wind",
*!*		    Entered: "< <TTOC(DATETIME(),3)> >",
*!*		    Address: {
*!*		        Street: "32 Kaiea",
*!*		        City: "Paia"
*!*		    },
*!*		    Orders: [
*!*		        { OrderId: "ar431211", OrderTotal: 125.44, Date: "< <TTOC(DATETIME(),3)> >Z"},
*!*		        { OrderId: "fe134341", OrderTotal: 95.12, Date: "< <TTOC(DATETIME(),3)>  >Z" }
*!*		    ]
*!*		}
*!*		ENDTEXT

*!*		loMongo.Save(lcJson,"Customers",.T.)
*!*	ENDFOR

*!*	this.MessageOut(TRANSFORM(lnCount) + " messages inserted in " + TRANSFORM(SECONDS() - lnStart))

*!*	ENDFUNC
*!*	*  RunManyInsertsWithJson




ENDDEFINE

