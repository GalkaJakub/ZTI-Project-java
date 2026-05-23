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

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    @GetMapping
    public List<GroupResponse> getCurrentUserGroups(Authentication authentication) {
        return groupService.getCurrentUserGroups(authentication.getName());
    }

    @PostMapping
    public GroupResponse createGroup(Authentication authentication, @Valid @RequestBody CreateGroupRequest request) {
        return groupService.createGroup(authentication.getName(), request.name());
    }

    @PostMapping("/join")
    public GroupResponse joinGroup(Authentication authentication, @Valid @RequestBody JoinGroupRequest request) {
        return groupService.joinGroup(authentication.getName(), request.inviteCode());
    }

    @GetMapping("/{groupId}/members")
    public List<GroupMemberResponse> getMembers(Authentication authentication, @PathVariable Long groupId) {
        return groupService.getMembers(authentication.getName(), groupId);
    }

    @DeleteMapping("/{groupId}/members/me")
    public void leaveGroup(Authentication authentication, @PathVariable Long groupId) {
        groupService.leaveGroup(authentication.getName(), groupId);
    }
}
