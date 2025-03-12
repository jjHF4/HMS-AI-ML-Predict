use RB19_Hosptal_Management_System;

CREATE TABLE employee_details (
    EmployeeDetailID INT PRIMARY KEY,
    EmployeeID smallint NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID)
);


BULK INSERT employee_details
FROM 'C:\\Users\\DELL\\Documents\\RB19\\Excel Sheets\\employeedetails.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';', -- Use ';' as per your file
    ROWTERMINATOR = '\n',
    TABLOCK
);

CREATE TABLE patient (
    PatientID smallint PRIMARY KEY, 
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DOB DATE,  -- Stores Date of Birth
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),  -- 'M' for Male, 'F' for Female, 'O' for Other
    created_at DATETIME DEFAULT GETDATE(),  -- Auto-fills the current timestamp if not provided
    Address VARCHAR(255) -- Stores patient address
);

BULK INSERT patient
FROM 'C:\\Users\\DELL\\Documents\\RB19\\Excel Sheets\\patient.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Adding foreign keys for EmployeeID in related tables
ALTER TABLE employee_details
ADD CONSTRAINT FK_employee_details_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

ALTER TABLE doctor_specialization
ADD CONSTRAINT FK_doctor_specialization_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

ALTER TABLE staff_training
ADD CONSTRAINT FK_staff_training_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

ALTER TABLE employee_department
ADD CONSTRAINT FK_employee_department_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

-- Adding foreign key for DepartmentID in employee_department
ALTER TABLE employee_department
ADD CONSTRAINT FK_employee_department_DepartmentID
FOREIGN KEY (DepartmentID) REFERENCES department(DepartmentID);

-- Adding foreign key for RoleID in employee table
ALTER TABLE employee
ADD CONSTRAINT FK_employee_RoleID
FOREIGN KEY (RoleID) REFERENCES role(RoleID);

-- Drop existing constraints if they exist
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_allergies_PatientID')
    ALTER TABLE patient_allergies DROP CONSTRAINT FK_patient_allergies_PatientID;
ALTER TABLE patient_allergies
ADD CONSTRAINT FK_patient_allergies_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_disease_PatientID')
    ALTER TABLE patient_disease DROP CONSTRAINT FK_patient_disease_PatientID;
ALTER TABLE patient_disease
ADD CONSTRAINT FK_patient_disease_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_disease_DiseaseID')
    ALTER TABLE patient_disease DROP CONSTRAINT FK_patient_disease_DiseaseID;
ALTER TABLE patient_disease
ADD CONSTRAINT FK_patient_disease_DiseaseID
FOREIGN KEY (DiseaseID) REFERENCES disease(DiseaseID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_billing_PatientID')
    ALTER TABLE patient_billing DROP CONSTRAINT FK_patient_billing_PatientID;
ALTER TABLE patient_billing
ADD CONSTRAINT FK_patient_billing_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_insurance_PatientID')
    ALTER TABLE patient_insurance DROP CONSTRAINT FK_patient_insurance_PatientID;
ALTER TABLE patient_insurance
ADD CONSTRAINT FK_patient_insurance_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_patient_insurance_InsuranceID')
    ALTER TABLE patient_insurance DROP CONSTRAINT FK_patient_insurance_InsuranceID;
ALTER TABLE patient_insurance
ADD CONSTRAINT FK_patient_insurance_InsuranceID
FOREIGN KEY (InsuranceID) REFERENCES insurance_claims(ClaimID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_prescription_PatientID')
    ALTER TABLE prescription DROP CONSTRAINT FK_prescription_PatientID;
ALTER TABLE prescription
ADD CONSTRAINT FK_prescription_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_prescription_EmployeeID')
    ALTER TABLE prescription DROP CONSTRAINT FK_prescription_EmployeeID;
ALTER TABLE prescription
ADD CONSTRAINT FK_prescription_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

-- Ambulance & Emergency

-- Foreign Key for emergency_records.PatientID → patient_register.PatientRegisterID
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_emergency_records_PatientID')
    ALTER TABLE emergency_records DROP CONSTRAINT FK_emergency_records_PatientID;
ALTER TABLE emergency_records
ADD CONSTRAINT FK_emergency_records_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

-- Foreign Key for emergency_records.DriverID → ambulance_drivers.DriverID
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_emergency_records_DriverID')
    ALTER TABLE emergency_records DROP CONSTRAINT FK_emergency_records_DriverID;
ALTER TABLE emergency_records
ADD CONSTRAINT FK_emergency_records_DriverID
FOREIGN KEY (DriverID) REFERENCES ambulance_drivers(DriverID);

-- Feedback & Marketing

-- Foreign Key for feedback.PatientID → patient_register.PatientRegisterID
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_feedback_PatientID')
    ALTER TABLE feedback DROP CONSTRAINT FK_feedback_PatientID;
ALTER TABLE feedback
ADD CONSTRAINT FK_feedback_PatientID
FOREIGN KEY (PatientID) REFERENCES patient_register(PatientRegisterID);

-- Foreign Key for feedback.EmployeeID → employee.EmployeeID
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_feedback_EmployeeID')
    ALTER TABLE feedback DROP CONSTRAINT FK_feedback_EmployeeID;
ALTER TABLE feedback
ADD CONSTRAINT FK_feedback_EmployeeID
FOREIGN KEY (EmployeeID) REFERENCES employee(EmployeeID);

-- 1. Link Marketing Campaigns to Patients (or Patient Register)
ALTER TABLE marketing_campaigns
ADD PatientID smallint NULL,
CONSTRAINT FK_Marketing_Patient FOREIGN KEY (PatientID) REFERENCES patient(PatientID);

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME IN ('facilities', 'material_availability') 
AND COLUMN_NAME = 'FacilityID';


-- 2. Link Asset Management to Facilities
ALTER TABLE asset_management
ADD FacilityID nvarchar(50) NULL,
CONSTRAINT FK_Asset_Facility FOREIGN KEY (FacilityID) REFERENCES facilities(FacilityID);

-- 3. Link Emergency Records to Ambulance Drivers
ALTER TABLE emergency_records
ADD CONSTRAINT FK_Emergency_Driver FOREIGN KEY (DriverID) REFERENCES ambulance_drivers(DriverID);

-- 4. Link Material Availability to Facilities
ALTER TABLE material_availability
ADD FacilityID nvarchar(50) NULL,
CONSTRAINT FK_Material_Facility FOREIGN KEY (FacilityID) REFERENCES facilities(FacilityID);

-- 5. Link Insurance Claims to Patient Billing
ALTER TABLE insurance_claims
ADD CONSTRAINT FK_Claims_Billing FOREIGN KEY (BillingID) REFERENCES patient_billing(BillingID);

ALTER TABLE appointment_followup
ADD CONSTRAINT FK_Claims_Appointment FOREIGN KEY (AppointmentID) REFERENCES patient_appiontment(AppointmentID);

ALTER TABLE medical_records
ADD CONSTRAINT FK_Medical_Patient FOREIGN KEY (PatientID) REFERENCES patient(PatientID);

ALTER TABLE emergency_contacts
ADD CONSTRAINT FK_Emergency_Patient FOREIGN KEY (PatientID) REFERENCES patient(PatientID);

ALTER TABLE patient_attendent
ADD CONSTRAINT FK_attendent_Patient FOREIGN KEY (PatientID) REFERENCES patient(PatientID);

ALTER TABLE labtest
ADD CONSTRAINT FK_labtest_Patient FOREIGN KEY (PatientID) REFERENCES patient(PatientID);

ALTER TABLE patient_rooms 
ADD CONSTRAINT FK_patientrooms_roomnumber FOREIGN KEY (RoomNumber) REFERENCES room_occupancy(RoomNumber);

ALTER TABLE pharmacy_stock  
ADD CONSTRAINT FK_PharmacyStock_Medication  
FOREIGN KEY (MedicationID) REFERENCES medication(MedicationID);

ALTER TABLE pharmacy_stock  
ADD InventoryID smallint
CONSTRAINT FK_PharmacyStock_Inventory  
FOREIGN KEY (InventoryID) REFERENCES pharmacy_inventory(InventoryID);

ALTER TABLE patient_register  
ADD CONSTRAINT FK_PatientRegister_Patient  
FOREIGN KEY (PatientID) REFERENCES patient(PatientID);




select * from pharmacy_stock;

select * from appointment_followup;

select * from patient_appointment;

select * from department;

select * from disease;

select * from doctor_specialization;

select * from emergency_records;

select * from emergency_contacts;

select * from employee

select * from employee_details

select *  from patient_allergies

select * from material_availability











