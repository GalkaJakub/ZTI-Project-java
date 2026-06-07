package wsp.controller;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import wsp.dto.CreateGroupRequest;
import wsp.dto.GroupMemberResponse;
import wsp.dto.GroupResponse;
import wsp.dto.JoinGroupRequest;
import wsp.service.GroupService;

import java.util.List;

/**
 * REST controller exposing operations for user groups and their memberships.
 */
@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    /**
     * Returns groups available to the currently authenticated user.
     *
     * @param authentication Spring Security authentication containing user email
     * @return list of group summaries
     */
    @GetMapping
    public List<GroupResponse> getCurrentUserGroups(Authentication authentication) {
        return groupService.getCurrentUserGroups(authentication.getName());
    }

    /**
     * Creates a new group and assigns the current user as its owner.
     *
     * @param authentication Spring Security authentication containing user email
     * @param request group creation data
     * @return created group summary
     */
    @PostMapping
    public GroupResponse createGroup(Authentication authentication, @Valid @RequestBody CreateGroupRequest request) {
        return groupService.createGroup(authentication.getName(), request.name());
    }

    /**
     * Adds the current user to a group identified by an invite code.
     *
     * @param authentication Spring Security authentication containing user email
     * @param request invite code request
     * @return joined group summary
     */
    @PostMapping("/join")
    public GroupResponse joinGroup(Authentication authentication, @Valid @RequestBody JoinGroupRequest request) {
        return groupService.joinGroup(authentication.getName(), request.inviteCode());
    }

    /**
     * Returns members of a group if the current user belongs to it.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     * @return list of group members
     */
    @GetMapping("/{groupId}/members")
    public List<GroupMemberResponse> getMembers(Authentication authentication, @PathVariable Long groupId) {
        return groupService.getMembers(authentication.getName(), groupId);
    }

    /**
     * Removes the current user from a group when business rules allow it.
     *
     * @param authentication Spring Security authentication containing user email
     * @param groupId group identifier
     */
    @DeleteMapping("/{groupId}/members/me")
    public void leaveGroup(Authentication authentication, @PathVariable Long groupId) {
        groupService.leaveGroup(authentication.getName(), groupId);
    }
}
