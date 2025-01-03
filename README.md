# Empowering PL/SQL with SQL Developer + Visual Studio and GitHub Copilot.

## 1. 💫 Overview
In this hands-on, we will work on a library model. In this scenario, we will become the developers and maintainers of the database system of a public library. The library administrators want to implement a database system that allows the following capabilities:
Register new book loans.
Return books.
Identify how many loans a person has.
Generate reports of the most loaned books.

For this, the following database model has been proposed to meet the requested requirement.

[Entity-Relationship Diagram](./copilot-library.md)

## 🎯️ Objectives.
- Configure SQL Developer Extension for Visual Studio Code.
- Build a database using GH Copilot based on an ER diagram from mermaid.
- Learn how to use GH Copilot for generating stored procedures.
- Learn how to use GH Copilot for building data validation triggers. (UPDATE, INSERT, DELETE).
- Learn how to use GH Copilot for generating reports.
Optimize queries with GH Copilot.

## 🛠️ Installation requirements.
- Visual Studio Code.
- Docker Desktop.
- Oracle SQL Developer Extension for VS Code
- Active GitHub Copilot License.
- GitHub Copilot extension for VS Code installed.


# 🖥️ Step-by-step

## 🔨 Step 1. Configuration of the Oracle Express Edition instance (if applicable)
To run an instance of Oracle SQL Express Edition (Oracle XE), we will use Docker, which is a tool for managing and running containers. To install an Oracle XE image, we must perform the following steps:

- Download Oracle XE: `docker pull container-registry.oracle.com/database/express:21.3.0-xe`
- Once the image is downloaded, create a new container that runs the Oracle XE instance with the following command:
```sh
docker run -d --name "oracle-xe" -p 1521:1521 -p 5500:5500 -e ORACLE_PWD="Password123" -e ORACLE_CHARACTERSET="AL32UTF8" container-registry.oracle.com/database/express:21.3.0-xe
```

> ### ⚠️ **WARNING: Installation on MacOS Apple Silicon systems**  
> Oracle Express Edition and other versions in general are not compatible with the ARM architecture present in the latest Apple chips (M1, M2, etc.). Therefore, directly running the command to build a container will result in a failure to connect to the database and an internal failure in the Oracle instance.  
>
> To see how we can **run an instance** of Oracle on MacOS computers with ARM Apple Silicon architecture click **[here](./apple-steps.md)**


> ### 🚧 **Info: Oracle XE Versions**  
> If you want to download a different image, go to the Oracle public container registry and locate the different available versions of Oracle Express Edition.

## 🔨 Step 2. Installation of Oracle SQL Developer Extension for VS Code. (If Applicable)

**SQL Developer Extension for VS Code:** https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developers

**Installation steps.**
- Open Visual Studio Code.
- Go to the extensions panel.
- Search for the extension: Oracle SQL Developer Extension for VS Code.
- Click on Install.

> **WARNING**  
> This extension may conflict with other similar SQL extensions within Visual Studio Code, such as the official **Microsoft SQL Server** extension provided by Microsoft. It is recommended to disable them to use SQL Developer for Visual Studio Code.

## 🔨 Step 3. Database connection

To connect, we go directly to the **Oracle SQL Developer** extension and click on the **"+"** icon. This will open a tab where we will enter the connection parameters. These parameters must match those defined in **step 1.**

**Connection Parameters:**
| Parameter           | Value         |
|---------------------|---------------|
| Connection Name     | SYSADMIN      |
| Authentication Type | Default       |
| Username            | SYS           |
| Password**          | YourPassword  |
| Connection Type     | Basic         |
| Hostname            | localhost     |
| Port                | 1521          |
| Type                | Service Name  |
| Service Name        | XEPDB1        |

(**) _The password value is suggested but can be modified as needed_

### 🚧 Troubleshooting
> **Connection error: SYSADMIN wrong role**  
> When connecting using the system user `SYS`, it is required to connect using the role: `SYSDBA` as this user is intended for full database administration operations.

### 👤 Library administrator user AdminBL
We will use Copilot to generate the SQL scripts that will allow the creation of a library administrator user. This user will be responsible for creating tables and managing stored procedures. We will do it using the following prompt:

`Create a user named AdminBL, who has permissions to create, delete, query, and update tables. They should also have permissions to create, delete, and execute stored procedures, and create, delete, and modify triggers. These scripts should be created for an Oracle XE database.`

_Copilot's response:_

```SQL
-- Create the user AdminBL
CREATE USER AdminBL IDENTIFIED BY your_password;

-- Grant permissions to create, delete, query, and update tables
GRANT CREATE TABLE TO AdminBL;
GRANT DROP TABLE TO AdminBL;
GRANT SELECT ANY TABLE TO AdminBL;
GRANT INSERT ANY TABLE TO AdminBL;
GRANT UPDATE ANY TABLE TO AdminBL;
GRANT DELETE ANY TABLE TO AdminBL;

-- Grant permissions to create, delete, and execute stored procedures
GRANT CREATE PROCEDURE TO AdminBL;
GRANT DROP PROCEDURE TO AdminBL;
GRANT EXECUTE ANY PROCEDURE TO AdminBL;

-- Grant permissions to create, delete, and modify triggers
GRANT CREATE TRIGGER TO AdminBL;
GRANT DROP TRIGGER TO AdminBL;
GRANT ALTER ANY TRIGGER TO AdminBL;

-- Grant additional necessary permissions
GRANT CREATE SESSION TO AdminBL;
```

> **Troubleshooting - Error: ORA-65096**  
> When we try to create the library user, we get the following error message:  
> Error report - ORA-65096: invalid common user or role name https://docs.oracle.com/error-help/db/ora-65096/65096. 00000 - "common user or role name must start with prefix %s"  
> *Cause: An attempt is being made to create a common user or role without the correct prefix as specified in the COMMON_USER_PREFIX parameter.*
>
> This is because we are connected to the database instance in a multitenant environment. To fix this, simply edit the connection parameters to the database and change the **SERVICE NAME** value to: **XEPDB1**


> **Password Replacement.**  
> It is necessary to replace the password value in the script with the value we want to use as the key. For this case, we will use biblioteca123, so the instruction should look like this:
> `CREATE USER AdminBL IDENTIFIED BY "biblioteca123";`

Once the new user **AdminBL** is created, we will connect in the same way as we did the previous connection.

## 🔨 Step 4. Schema creation

We have the entity-relationship model created with Mermaid to generate the SQL instructions that create the schema in the database. We will use Copilot to translate the Mermaid diagram into SQL code compatible with Oracle SQL.

> **NOTE: AdminBL User**  
> From this point on, all scripts will be executed with the **AdminBL** user. The SYS user should not be used to continue operations.

_Prompt to generate the table schema:_

`Hello Copilot, for this task I provide you with a markdown file which contains an entity-relationship diagram created with the Mermaid tool. Your goal is to interpret, understand, and process that diagram. Once you have processed the diagram, I need you to construct the SQL scripts that will allow the creation of tables, relationships, constraints, and other elements that will enable the creation of a database based 100% on that diagram. It is essential that all the scripts you generate are 100% compatible with Oracle SQL Express Edition databases. #file:copilot-library.md`

We instruct Copilot to adjust the script slightly to modify the size of some fields:

`Make some modifications to the script. The ISBN in the BOOKS table is an alphanumeric code that can occupy a maximum of 25 characters. The username field in the USUARIO table can contain up to a maximum of 20 characters. The numeric code of the librarians is a unique numeric code that can have a size of 8 digits.`

_Generated output by GitHub Copilot:_

```SQL
-- Create the BOOKS table with modified ISBN length
CREATE TABLE BOOKS (
    BookID NUMBER PRIMARY KEY,
    ISBN VARCHAR2(25) UNIQUE,
    Title VARCHAR2(255),
    Author VARCHAR2(255),
    Genre VARCHAR2(100),
    Available NUMBER
);

-- Create the USERS table with modified Username length
CREATE TABLE USERS (
    UserID NUMBER PRIMARY KEY,
    DNI VARCHAR2(20) UNIQUE,
    Name VARCHAR2(255),
    Email VARCHAR2(255) UNIQUE,
    Phone VARCHAR2(20),
    Username VARCHAR2(20) UNIQUE
);

-- Create the LIBRARIANS table with modified Code length
CREATE TABLE LIBRARIANS (
    LibrarianID NUMBER PRIMARY KEY,
    Name VARCHAR2(255),
    Email VARCHAR2(255),
    Code NUMBER(8) UNIQUE
);

-- Create the LOANS table
CREATE TABLE LOANS (
    LoanID NUMBER PRIMARY KEY,
    BookID NUMBER,
    UserID NUMBER,
    LibrarianID NUMBER,
    LoanDate DATE,
    ReturnDate DATE,
    CONSTRAINT fk_book FOREIGN KEY (BookID) REFERENCES BOOKS(BookID),
    CONSTRAINT fk_user FOREIGN KEY (UserID) REFERENCES USERS(UserID),
    CONSTRAINT fk_librarian FOREIGN KEY (LibrarianID) REFERENCES LIBRARIANS(LibrarianID)
);
```

## 🔨 Step 5. Data generation.

We proceed to fill the library database with data. Using GitHub Copilot, SQL scripts will be constructed to load information into the tables.

_Prompt to generate test data:_

`@workspace /new Generate a folder called data, which contains SQL insertion scripts for the tables existing in the file #file:schema.sql. The BOOKS table must contain 10 different books, no book can be repeated. The USERS table must have at least 20 users. The LIBRARIANS table must contain 7 librarians. Do not insert any records into the LOANS table. The data folder is the main folder of the project, the scripts must be placed inside that folder. A user cannot be a librarian and vice versa. All scripts must be created with Oracle SQL syntax.`

With `@workspace /new` a new file structure will be generated. You must click on the **Create Workspace** button and place the generated structure in the root directory of the current working repository.

The output of this script should return a folder called Data which contains three SQL insertion scripts for the **USERS**, **BOOKS**, and **LIBRARIANS** tables.

Once this is done, we simply need to execute the scripts in the database using the **AdminBL** user.

> **ERROR: Quota on data insertion.**  
> If the error of quota not available for the logged-in user occurs when inserting data, it is resolved with the following SQL instruction:  
> `ALTER USER AdminBL QUOTA UNLIMITED ON USERS;`  
> This instruction allows unlimited quota to the AdminBL user.

## 🔨 Step 6. Loan Registration Procedure.

The main operation of the library is to loan books. We will use GitHub Copilot to generate a procedure that allows registering book loans in the library using the following prompt:

`I want to create a new stored procedure in PL/SQL that allows me to register book loans. I want the procedure to receive as input parameters the DNI of the user requesting the loan, the ISBN code of the book, and the code of the librarian authorizing/performing the loan. #file:schema.sql. This procedure will be called RegisterLoan`

_Code suggested by Copilot:_

```SQL
-- An auto-increment sequence with values of 1 called PRESTAMOS_SEQ is generated
CREATE SEQUENCE PRESTAMOS_SEQ START WITH 1 INCREMENT BY 1;
```

```SQL
CREATE OR REPLACE PROCEDURE RegisterLoan (
    p_DNI IN USERS.DNI%TYPE,
    p_ISBN IN BOOKS.ISBN%TYPE,
    p_LibrarianCode IN LIBRARIANS.Code%TYPE
) AS
    v_UserID USERS.UserID%TYPE;
    v_BookID BOOKS.BookID%TYPE;
    v_LibrarianID LIBRARIANS.LibrarianID%TYPE;
BEGIN
    -- Get the UserID from the DNI
    SELECT UserID INTO v_UserID
    FROM USERS
    WHERE DNI = p_DNI;

    -- Get the BookID from the ISBN
    SELECT BookID INTO v_BookID
    FROM BOOKS
    WHERE ISBN = p_ISBN;

    -- Get the LibrarianID from the Code
    SELECT LibrarianID INTO v_LibrarianID
    FROM LIBRARIANS
    WHERE Code = p_LibrarianCode;

    -- Insert the loan record
    INSERT INTO LOANS (LoanID, BookID, UserID, LibrarianID, LoanDate)
    VALUES (LOANS_SEQ.NEXTVAL, v_BookID, v_UserID, v_LibrarianID, SYSDATE);

    -- Update the availability of the book
    UPDATE BOOKS
    SET Available = Available - 1
    WHERE BookID = v_BookID;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'User, Book, or Librarian not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END RegisterLoan;
/
```

To use the stored procedure, it is enough to invoke it from a query or an anonymous block. We will ask Copilot to construct an anonymous block where it requests input data from the user to execute the procedure.



_Prompt to generate anonymous PL/SQL block and procedure execution_

```
Construct an anonymous PL/SQL block that executes the stored procedure we just generated. It should request the necessary parameters from the user for the stored procedure to function correctly.
```
_Code generated by Copilot:_

```SQL
DECLARE
    v_DNI USERS.DNI%TYPE;
    v_ISBN BOOKS.ISBN%TYPE;
    v_LibrarianCode LIBRARIANS.Code%TYPE;
BEGIN
    -- Request the DNI of the user
    DBMS_OUTPUT.PUT_LINE('Enter the DNI of the user:');
    v_DNI := '&v_DNI';

    -- Request the ISBN of the book
    DBMS_OUTPUT.PUT_LINE('Enter the ISBN of the book:');
    v_ISBN := '&v_ISBN';

    -- Request the code of the librarian
    DBMS_OUTPUT.PUT_LINE('Enter the code of the librarian:');
    v_LibrarianCode := '&v_LibrarianCode';

    -- Call the RegisterLoan procedure
    RegisterLoan(v_DNI, v_ISBN, v_LibrarianCode);

    DBMS_OUTPUT.PUT_LINE('Loan registered successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```

### Validation adjustments

#### Loan due date.
If you look closely, Copilot is not generating the insertion of values in the ReturnDate field of the PROCEDURES table. Therefore, we will request that the return date of a loan be 10 days after its creation date. (It is possible to define a parameter to enter any date, but to simplify things we will use a 10-day window). We will do it using the following prompt:

`Modify the RegisterLoan procedure so that the ReturnDate field defined in the LOANS table in the schema #file:schema.sql has as its value the loan creation date + 10 days.`

This prompt will generate the stored procedure with the change applied when inserting a loan into the database.

#### Loan validation.
We must also include a validation to check if there is availability of books before executing a loan. This is achieved using the following prompt:

`Modify the RegisterLoan procedure to include a condition or validation where it checks that the Available field of the book to be loaned is not zero. If the value of that field is ZERO, raise an error with the message: Book not available.`

This will modify the stored procedure to include a validation to check that the book to be loaned is available.


```SQL
CREATE OR REPLACE PROCEDURE RegisterLoan (
    p_DNI IN USERS.DNI%TYPE,
    p_ISBN IN BOOKS.ISBN%TYPE,
    p_LibrarianCode IN LIBRARIANS.Code%TYPE
) AS
    v_UserID USERS.UserID%TYPE;
    v_BookID BOOKS.BookID%TYPE;
    v_LibrarianID LIBRARIANS.LibrarianID%TYPE;
    v_Available BOOKS.Available%TYPE;
BEGIN
    -- Get the UserID from the DNI
    SELECT UserID INTO v_UserID
    FROM USERS
    WHERE DNI = p_DNI;

    -- Get the BookID and Available from the ISBN
    SELECT BookID, Available INTO v_BookID, v_Available
    FROM BOOKS
    WHERE ISBN = p_ISBN;

    -- Check if the book is available
    IF v_Available = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Book not available');
    END IF;

    -- Get the LibrarianID from the Code
    SELECT LibrarianID INTO v_LibrarianID
    FROM LIBRARIANS
    WHERE Code = p_LibrarianCode;

    -- Insert the loan record with ReturnDate as LoanDate + 10 days
    INSERT INTO LOANS (LoanID, BookID, UserID, LibrarianID, LoanDate, ReturnDate)
    VALUES (LOANS_SEQ.NEXTVAL, v_BookID, v_UserID, v_LibrarianID, SYSDATE, SYSDATE + 10);

    -- Update the availability of the book
    UPDATE BOOKS
    SET Available = Available - 1
    WHERE BookID = v_BookID;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'User, Book, or Librarian not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END RegisterLoan;
/

```

> **NOTE: Compilation of PL/SQL procedures**  
> Whenever a stored procedure is modified, it must be re-executed to recompile and update it in the database. Otherwise, the modifications will not be reflected.

## 🔨 Step 7. Trigger to update availability after a loan.

The loan registration procedure works perfectly, however, it is not controlling the count of book availability each time a loan occurs. We will handle this functionality with a trigger that, each time an insertion occurs in the loans table, will update the number of available books according to the corresponding book.

`I need you to develop a TRIGGER called UpdateAvailability. This trigger will be responsible for updating the availability of a book each time a loan is made, that is, each time a new loan record is inserted. The availability of each book is controlled with a field called Available in the BOOKS table. For each loan made, the value of this field should decrease by 1. #file:schema.sql`

_Code suggested by Copilot:_

```SQL
CREATE OR REPLACE TRIGGER UpdateAvailability
AFTER INSERT ON LOANS
FOR EACH ROW
BEGIN
    UPDATE BOOKS
    SET Available = Available - 1
    WHERE BookID = :NEW.BookID;
END;
/
```
This trigger will update the availability each time a new loan record is inserted.

## 🔨 Step 8. Book return procedure.

It is also necessary to create a procedure that allows registering when users return a book to the library. For this, we will need to modify the loans table and add a new field called Return, which will be a boolean indicating whether a loan has been returned or not. Subsequently, we will use GitHub Copilot to generate the PL/SQL procedure code that will handle this task.

_Prompt for modifying the loans table:_

`Modify the Loans table to now include a boolean field called Return, the default value of this field is false. This field exists to validate whether a loan has been returned or not.`

```SQL
ALTER TABLE LOANS
ADD Return NUMBER(1) DEFAULT 0 CHECK (Return IN (0, 1));
```

_Prompt for creating the book return stored procedure:_

`I want to create a stored procedure in PL/SQL that allows me to register the returns of books that had been loaned by the library. This procedure must validate that the loan is active and will receive the loan ID as a parameter. #file:schema.sql`

```SQL
CREATE OR REPLACE PROCEDURE RegisterReturn (
    p_LoanID IN LOANS.LoanID%TYPE
) AS
    v_BookID BOOKS.BookID%TYPE;
    v_ReturnStatus LOANS.Return%TYPE;
BEGIN
    -- Get the BookID and Return status from the LoanID
    SELECT BookID, Return INTO v_BookID, v_ReturnStatus
    FROM LOANS
    WHERE LoanID = p_LoanID;

    -- Check if the loan is active
    IF v_ReturnStatus = 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Loan has already been returned');
    END IF;

    -- Update the loan record to mark it as returned
    UPDATE LOANS
    SET Return = 1
    WHERE LoanID = p_LoanID;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Loan not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END RegisterReturn;
/
```

> **Availability update**  
> If you look closely at the response given by Copilot, in this stored procedure, the logic to implement the availability update has been included. In this case, we will remove it since we will create a trigger that will execute specifically for this task. In the previous example, **remove the code from line 22 to line 25**.

### We use comment-driven development to execute the procedure.
1. Create a new file called `return.sql`.
2. Write the following comment inside the created SQL file:
`-- Create an anonymous block that executes the stored procedure RegisterLoan`.
3. Press `Enter` and `Tab` to accept the suggestions provided by GitHub Copilot.

_Resulting code block:_
```SQL
-- Create an anonymous block that executes the stored procedure RegisterLoan

DECLARE
    v_LoanID LOANS.LoanID%TYPE := &LoanID;
BEGIN

    -- Call the RegisterReturn procedure
    RegisterReturn(v_LoanID);

    DBMS_OUTPUT.PUT_LINE('Return registered successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);

```

## 🔨 Step 9. Trigger to update availability after a return.

We will build a trigger similar to the one for loans, but with the difference that this trigger will detect changes in records when a return occurs, increasing the count of available book copies again.

_Prompt to generate the trigger:_

`I need you to develop a TRIGGER called UpdateAvailability. This trigger will be responsible for updating the availability of a book each time a return is made, that is, each time the Return field of the loan table is updated to the value 'T'. The availability of each book is controlled with a field called Available in the BOOKS table. For each book return made, the value of this field should increase by 1. #file:schema.sql`

_Code suggested by GitHub Copilot_

```SQL
CREATE OR REPLACE TRIGGER UpdateAvailability
AFTER UPDATE OF Return ON LOANS
FOR EACH ROW
WHEN (NEW.Return = 1)
BEGIN
    UPDATE BOOKS
    SET Available = Available + 1
    WHERE BookID = :NEW.BookID;
END;
/
```

## 👾 Bonus.!!

At this point, we have completed the basic functionalities of the proposed library model, however, we can add some more visibility. That is why it is proposed to use Copilot to generate the following queries.

- Get the list of delinquent users: Users who have pending loans.
- Get the list of most loaned books.
- Create a procedure for registering new books.

