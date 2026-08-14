CREATE TABLE [dbo].[UserConnections] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [UserId]          INT           NOT NULL,
    [ConnectedUserId] INT           NOT NULL,
    [Status]          NVARCHAR (20) NOT NULL,
    [RequestedAt]     DATETIME2 (7) DEFAULT (getutcdate()) NOT NULL,
    [AcceptedAt]      DATETIME2 (7) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CHK_UserConnections_NotSelf] CHECK ([UserId]<>[ConnectedUserId]),
    CONSTRAINT [FK_UserConnections_Connected] FOREIGN KEY ([ConnectedUserId]) REFERENCES [dbo].[UserProfiles] ([Id]),
    CONSTRAINT [FK_UserConnections_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProfiles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_UserConnections_User_Connected] UNIQUE NONCLUSTERED ([UserId] ASC, [ConnectedUserId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_UserConnections_UserId]
    ON [dbo].[UserConnections]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserConnections_Status]
    ON [dbo].[UserConnections]([Status] ASC);

