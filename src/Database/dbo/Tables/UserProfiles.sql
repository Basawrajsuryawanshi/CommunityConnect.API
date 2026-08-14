CREATE TABLE [dbo].[UserProfiles] (
    [Id]              INT            NOT NULL,
    [FullName]        NVARCHAR (255) NOT NULL,
    [Email]           NVARCHAR (255) NULL,
    [MobileNumber]    NVARCHAR (10)  NOT NULL,
    [SchoolName]      NVARCHAR (255) NOT NULL,
    [State]           NVARCHAR (100) NOT NULL,
    [SchoolRegion]    NVARCHAR (100) NOT NULL,
    [PassoutYear]     INT            NOT NULL,
    [Role]            NVARCHAR (50)  NOT NULL,
    [University]      NVARCHAR (255) NOT NULL,
    [CurrentState]    NVARCHAR (100) NOT NULL,
    [CurrentDistrict] NVARCHAR (100) NOT NULL,
    [BloodGroup]      NVARCHAR (5)   NOT NULL,
    [CreatedAt]       DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]       DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserProfiles_Users] FOREIGN KEY ([Id]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_UserProfiles_SchoolName]
    ON [dbo].[UserProfiles]([SchoolName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserProfiles_PassoutYear]
    ON [dbo].[UserProfiles]([PassoutYear] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserProfiles_Email]
    ON [dbo].[UserProfiles]([Email] ASC);

