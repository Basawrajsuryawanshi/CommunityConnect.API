CREATE TABLE [dbo].[Users] (
    [Id]                      INT            IDENTITY (1, 1) NOT NULL,
    [Email]                   NVARCHAR (255) NOT NULL,
    [PasswordHash]            NVARCHAR (500) NULL,
    [EmailVerified]           BIT            DEFAULT ((0)) NOT NULL,
    [EmailVerificationToken]  NVARCHAR (500) NULL,
    [EmailVerificationExpiry] DATETIME2 (7)  NULL,
    [PasswordResetToken]      NVARCHAR (500) NULL,
    [PasswordResetExpiry]     DATETIME2 (7)  NULL,
    [IsActive]                BIT            DEFAULT ((1)) NOT NULL,
    [IsDeleted]               BIT            DEFAULT ((0)) NOT NULL,
    [CreatedAt]               DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]               DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [LastLoginAt]             DATETIME2 (7)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Users_Email]
    ON [dbo].[Users]([Email] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Users_EmailVerificationToken]
    ON [dbo].[Users]([EmailVerificationToken] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Users_PasswordResetToken]
    ON [dbo].[Users]([PasswordResetToken] ASC);

