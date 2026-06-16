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
 * Kontroler REST udostępniający operacje na grupach użytkowników i członkostwach.
 */
@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupService groupService;

    /**
     * Tworzy kontroler grup z serwisem logiki biznesowej grup.
     *
     * @param groupService serwis obsługujący grupy i członkostwa
     */
    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    /**
     * Zwraca grupy dostępne dla aktualnie uwierzytelnionego użytkownika.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @return lista podsumowań grup
     */
    @GetMapping
    public List<GroupResponse> getCurrentUserGroups(Authentication authentication) {
        return groupService.getCurrentUserGroups(authentication.getName());
    }

    /**
     * Tworzy nową grupę i przypisuje aktualnego użytkownika jako właściciela.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param request dane tworzonej grupy
     * @return podsumowanie utworzonej grupy
     */
    @PostMapping
    public GroupResponse createGroup(Authentication authentication, @Valid @RequestBody CreateGroupRequest request) {
        return groupService.createGroup(authentication.getName(), request.name());
    }

    /**
     * Dodaje aktualnego użytkownika do grupy wskazanej kodem zaproszenia.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param request żądanie zawierające kod zaproszenia
     * @return podsumowanie grupy, do której dołączono
     */
    @PostMapping("/join")
    public GroupResponse joinGroup(Authentication authentication, @Valid @RequestBody JoinGroupRequest request) {
        return groupService.joinGroup(authentication.getName(), request.inviteCode());
    }

    /**
     * Zwraca członków grupy, jeśli aktualny użytkownik do niej należy.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     * @return lista członków grupy
     */
    @GetMapping("/{groupId}/members")
    public List<GroupMemberResponse> getMembers(Authentication authentication, @PathVariable Long groupId) {
        return groupService.getMembers(authentication.getName(), groupId);
    }

    /**
     * Usuwa aktualnego użytkownika z grupy, jeśli pozwalają na to reguły biznesowe.
     *
     * @param authentication obiekt uwierzytelnienia Spring Security z adresem e-mail użytkownika
     * @param groupId identyfikator grupy
     */
    @DeleteMapping("/{groupId}/members/me")
    public void leaveGroup(Authentication authentication, @PathVariable Long groupId) {
        groupService.leaveGroup(authentication.getName(), groupId);
    }
}
