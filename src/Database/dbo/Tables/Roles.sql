CREATE TABLE [dbo].[Roles] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    [CreatedAt]   DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Name] ASC)
);

