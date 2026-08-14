CREATE TABLE [dbo].[UserRoleAssignments] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [UserId]     INT           NOT NULL,
    [RoleId]     INT           NOT NULL,
    [AssignedAt] DATETIME2 (7) DEFAULT (getutcdate()) NOT NULL,
    [AssignedBy] INT           NULL,
    [ExpiresAt]  DATETIME2 (7) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserRoleAssignments_Roles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_UserRoleAssignments_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProfiles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_UserRoleAssignments_User_Role] UNIQUE NONCLUSTERED ([UserId] ASC, [RoleId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_UserRoleAssignments_UserId]
    ON [dbo].[UserRoleAssignments]([UserId] ASC);

